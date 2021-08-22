--  hello-world.schema.lua
local typedefs = require "kong.db.schema.typedefs"
return {
  name = "hello-world",
  fields = {
      {
          consumer = typedefs.no_consumer
      },
      {
          config = {
              type = "record",
              fields = {
                  {
                      username = {-- 这里的username, 会显示在插件配置页
                        type = "string"
                        --   type = "array",
                        --   elements = {type = "string"},
                        --   default = {}                            
                      }
                  }
              }
          }
      }
  }
}
