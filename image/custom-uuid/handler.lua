-- handler.lua (必需)包含请求的生命周期, 提供接口来实现插件逻辑

local uuid = require "kong.tools.utils".uuid

local MyUUIDHandler = {}

MyUUIDHandler.PRIORITY = 1
MyUUIDHandler.VERSION = "0.1.0"



-- 针对客户端的每个请求并在将其代理到上游服务之前执行
function MyUUIDHandler:access(conf)
  -- Set header for upstream
  local trace_id = kong.request.get_header(conf.header_name)
  if not trace_id or trace_id == "" then
    -- Generate the header value
    trace_id = uuid()
    if trace_id then
      kong.service.request.set_header(conf.header_name, trace_id)
    end
  end

  kong.ctx.plugin.trace_id = trace_id
end

-- 当已从上游服务接收到所有响应头字节时执行
function MyUUIDHandler:header_filter(conf)
  local trace_id = kong.ctx.plugin.trace_id or
                         kong.request.get_header(conf.header_name)

  if not trace_id or trace_id == "" then
    trace_id = uuid()
  end

  kong.response.set_header(conf.header_name, trace_id)
end

return MyUUIDHandler
