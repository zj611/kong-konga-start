local BasePlugin = require "kong.plugins.base_plugin"
local prometheus = require "kong.plugins.prometheus.exporter"
local basic_serializer = require "kong.plugins.log-serializers.basic"


local PrometheusHandler = BasePlugin:extend()
PrometheusHandler.PRIORITY = 13
PrometheusHandler.VERSION = "0.1.0"


local function log(premature, conf, message)
  if premature then
    return
  end

  prometheus.log(message)
end


function PrometheusHandler:new()
  PrometheusHandler.super.new(self, "prometheus")
  return prometheus.init()
end


function PrometheusHandler:log(conf)
  PrometheusHandler.super.log(self)

  local message = basic_serializer.serialize(ngx)
  local ok, err = ngx.timer.at(0, log, conf, message)
  if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
  end
end


return PrometheusHandler
