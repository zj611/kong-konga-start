---
--- Created by linhuali.
--- DateTime: 2018/4/28 上午10:25
---
local BasePlugin = require "kong.plugins.base_plugin"

local ngx_error = ngx.ERR
local ngx_log = ngx.log
local ngx_timer_at = ngx.timer.at
local http = require "resty.http"
local json = require "kong.plugins.custom-http-apis.json"

local DATAHandler = BasePlugin:extend()

DATAHandler.PRIORITY = 1300
DATAHandler.VERSION = "0.1.0"

function DATAHandler:new()
    DATAHandler.super.new(self, "custom-http-apis")
end

local function send(premature, value, conf)
    if premature then
        return
    end
    local json_value = json.encode(value)
    local httpc = http.new()
    httpc:set_timeout(conf.timeout)
    local ok, err = httpc:connect(conf.host, conf.port)
    if (not ok) or err ~= nil then
        ngx_log(ngx_error, "failed to create http  err:", err, json_value)
    end
    local body = "obj=" .. json_value
    local res, err = httpc:request({
        path = conf.uri,
        method = "POST",
        body = body,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
    })
    if not res then
        ngx_log(ngx_error, "failed to send http data err:", err, json_value)
        return false
    end
    local body = res:read_body()
    if body ~= "true" then
        ngx_log(ngx_error, "failed to send api data err:", err, json_value)
        return
    end
    http:close()
end

function DATAHandler:log(conf)
    DATAHandler.super.log(self)
    local ctx = ngx.ctx
    local route = ctx.route
    local svc = ctx.service
    local now = ngx.now()
    local createdAt = os.date("%Y-%m-%d %H:%M:%S", ngx.time())
    local authenticated_consumer = ctx.authenticated_consumer
    local apikey = ctx.apikey
    local status = ngx.var.status
    local value = {
        now = now,
        createdAt = createdAt,
        route = route,
        svc = svc,
        consumer = authenticated_consumer,
        apikey = apikey,
        status = status,
    }
    local ok, err = ngx_timer_at(0, send, value, conf)
    if not ok then
        ngx_log(ngx_error, "failed to create timer: ", err)
    end
    ngx_log(ngx_error, "send gw svc host:" .. svc.host)
end

return DATAHandler