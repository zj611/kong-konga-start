local singletons = require "kong.singletons"
local responses = require "kong.tools.responses"
local find = string.find
local select = select
local ERR = ngx.ERR
local WARN = ngx.WARN
local ngx_log = ngx.log


local DEFAULT_BUCKETS = { 1, 2, 5, 7, 10, 15, 20, 25, 30, 40, 50, 60, 70,
                          80, 90, 100, 200, 300, 400, 500, 1000,
                          2000, 5000, 10000, 30000, 60000 }
local metrics = {}
local prometheus


local function init()
  local shm = "prometheus_metrics"
  if not ngx.shared.prometheus_metrics then
    ngx_log(ERR, "prometheus: ngx shared dict 'prometheus_metrics' not found")
    return
  end

  prometheus = require("kong.plugins.prometheus.prometheus").init(shm, "kong_")

  -- accross all services
  metrics.connections = prometheus:gauge("nginx_http_current_connections",
                                         "Number of HTTP connections",
                                         {"state"})
  metrics.db_reachable = prometheus:gauge("datastore_reachable",
                                          "Datastore reachable from Kong, 0 is unreachable")
  metrics.status_total = prometheus:counter("http_status_total",
                                            "HTTP status codes aggreggated across all services in Kong",
                                            {"code"})
  metrics.latency_total = prometheus:histogram("latency_total",
                                               "Latency added by Kong, total request time and upstream latency aggreggated across all services in Kong",
                                               {"type"},
                                               DEFAULT_BUCKETS) -- TODO make this configurable
  metrics.bandwidth_total = prometheus:counter("bandwidth_total",
                                               "Total bandwidth in bytes for all proxied requests in Kong",
                                               {"type"})

  -- per service
  metrics.status = prometheus:counter("http_status",
                                      "HTTP status codes per service in Kong",
                                      {"code", "service"})
  metrics.latency = prometheus:histogram("latency",
                                         "Latency added by Kong, total request time and upstream latency for each service in Kong",
                                         {"type", "service"},
                                         DEFAULT_BUCKETS) -- TODO make this configurable
  metrics.bandwidth = prometheus:counter("bandwidth",
                                         "Total bandwidth in bytes consumed per service in Kong",
                                         {"type", "service"})
end


local function log(message)
  if not metrics then
    ngx_log(ERR, "prometheus: can not log metrics because of an initialization "
            .. "error, please make sure that you've declared "
            .. "'prometheus_metrics' shared dict in your nginx template")
    return
  end

  local service_name = message.service and message.service.name or
                       message.service.host
  service_name = service_name or ""

  metrics.status:inc(1, { message.response.status, service_name })
  metrics.status_total:inc(1, { message.response.status })

  local request_size = tonumber(message.request.size)
  if request_size and request_size > 0 then
    metrics.bandwidth:inc(request_size, { "ingress", service_name })
    metrics.bandwidth_total:inc(request_size, { "ingress" })
  end

  local response_size = tonumber(message.response.size)
  if response_size and response_size > 0 then
    metrics.bandwidth:inc(response_size, { "egress", service_name })
    metrics.bandwidth_total:inc(response_size, { "egress" })
  end

  local request_latency = tonumber(message.latencies.request)
  if request_latency and request_latency >= 0 then
    metrics.latency:observe(request_latency, { "request", service_name })
    metrics.latency_total:observe(request_latency, { "request" })
  end

  local upstream_latency = tonumber(message.latencies.proxy)
  if upstream_latency ~= nil and upstream_latency >= 0 then
    metrics.latency:observe(upstream_latency, {"upstream", service_name })
    metrics.latency_total:observe(upstream_latency, { "upstream" })
  end

  local kong_proxy_latency = tonumber(message.latencies.kong)
  if kong_proxy_latency ~= nil and kong_proxy_latency >= 0 then
    metrics.latency:observe(kong_proxy_latency, { "kong", service_name })
    metrics.latency_total:observe(kong_proxy_latency, { "kong" })
  end
end


local function collect()
  if not prometheus or not metrics then
    ngx_log(ERR, "prometheus: plugin is not initialized, please make sure ",
            " 'prometheus_metrics' shared dict is present in nginx template")
    return responses.send_HTTP_INTERNAL_SERVER_ERROR()
  end

  local r = ngx.location.capture "/nginx_status"

  if r.status ~= 200 then
    ngx_log(WARN, "prometheus: failed to retrieve /nginx_status ",
            "whlie processing /metrics endpoint")

  else
    local accepted, handled, total = select(3, find(r.body,
                                            "accepts handled requests\n (%d*) (%d*) (%d*)"))
    metrics.connections:set(accepted, { "accepted" })
    metrics.connections:set(handled, { "handled" })
    metrics.connections:set(total, { "total" })
  end

  metrics.connections:set(ngx.var.connections_active, { "active" })
  metrics.connections:set(ngx.var.connections_reading, { "reading" })
  metrics.connections:set(ngx.var.connections_writing, { "writing" })
  metrics.connections:set(ngx.var.connections_waiting, { "waiting" })

  -- db reachable?
  local dao = singletons.dao
  local ok, err = dao.db:reachable()
  if ok then
    metrics.db_reachable:set(1)

  else
    metrics.db_reachable:set(0)
    ngx_log(ERR, "prometheus: failed to reach database while processing",
            "/metrics endpoint: ", err)
  end

  prometheus:collect()
  return ngx.exit(200)
end


return {
  init    = init,
  log     = log,
  collect = collect,
}
