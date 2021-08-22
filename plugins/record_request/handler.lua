-- handler.lua (必需)包含请求的生命周期, 提供接口来实现插件逻辑

local uuid = require "kong.tools.utils".uuid

local RecordRequestHandler = {}

RecordRequestHandler.PRIORITY = 1
RecordRequestHandler.VERSION  = "2.2.0"


local function insert_recode(trace_id,server_name)
  local inserted_record, err = kong.db.record_request:insert({
    key = trace_id,
    server_name = server_name
  })
  if err then
    kong.log(err)
    return nil, err
  end
  return inserted_record,nil
end


function RecordRequestHandler:access(conf)

  kong.log("hello ", "world")

  local trace_id = uuid()

  -- Set header for upstream
  local record_header_msg = kong.request.get_header(conf.header_name)
  kong.log(record_header_msg)

  if not record_header_msg or record_header_msg == "" then

    -- return nil, { status = 415, message = "The request is in a format not supported by the requested resource for the requested method" }
    
    local err = { status = 415, message = "The request is in a format not supported by the requested resource for the requested method" }
    return kong.response.error(err.status, err.message, err.headers)

    -- Generate the header value
    -- trace_id = uuid()
    -- if trace_id then
    --   kong.service.request.set_header(conf.header_name, trace_id)
    -- end
  end

  kong.log("record_header_msg before")
  local inserted_record,err = insert_recode(trace_id,record_header_msg)
  if err then
    kong.log("500")

    err = { status = 500, message = "The server encountered an error and was unable to complete the request." }
    return kong.response.error(err.status, err.message, err.headers)
  end

  kong.log("inserted_record",  inserted_record)

  -- kong.ctx.plugin.trace_id = trace_id
end

-- 当已从上游服务接收到所有响应头字节时执行
-- function MyUUIDHandler:header_filter(conf)
--   local trace_id = kong.ctx.plugin.trace_id or
--                          kong.request.get_header(conf.header_name)

--   if not trace_id or trace_id == "" then
--     trace_id = uuid()
--   end

--   kong.response.set_header(conf.header_name, trace_id)
-- end

return RecordRequestHandler
