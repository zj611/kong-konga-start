-- hello-world.handlar.lua
local BasePlugin = require "kong.plugins.base_plugin"

local CustomHandler = BasePlugin:extend()

local resultAns = ">>插件开始运行了\n"

-- CustomHandler.VERSION = "1.0.0"
-- CustomHandler.PRIORITY = 10

CustomHandler.PRIORITY = 1
CustomHandler.VERSION = "0.1.0"

function CustomHandler:new()
  CustomHandler.super.new(self, "hello-world")
end

function CustomHandler:access(config)
  CustomHandler.super.access(self)  

  resultAns = resultAns .. ">>>>>>>执行：access阶段开始\n输出嵌入的内容(请求在还未到达上游服务器)：\n"
  resultAns = resultAns .. "kong.version：\t" .. kong.version .. "\n"
  resultAns = resultAns .. "kong.client.get_ip()：\t" .. kong.client.get_ip() .. "\n" 
  resultAns = resultAns .. "kong.request.get_scheme()：\t" .. kong.request.get_scheme() .. "\n"
  resultAns = resultAns .. "kong.request.get_host()：\t" .. kong.request.get_host() .. "\n"
  resultAns = resultAns .. "kong.request.get_port()\t：" .. kong.request.get_port() .. "\n"
  resultAns = resultAns .. "kong.request.get_http_version()：\t" .. kong.request.get_http_version() .. "\n"
  resultAns = resultAns .. "kong.request.get_method()：\t" .. kong.request.get_method() .. "\n"
  resultAns = resultAns .. "kong.request.get_path()：\t" .. kong.request.get_path() .. "\n"
  resultAns = resultAns .. "kong.request.username()：\t" .. config.username .. "\n"
  resultAns = resultAns .. "<<<<<<<执行access阶段结束 \n" 

  return kong.response.exit(
      200,
      resultAns,
      {
          ["Content-Type"] = "application/json",
          ["WWW-Authenticate"] = "Basic"
      }
  )
end 

return CustomHandler
