local typedefs = require "kong.db.schema.typedefs"
-- (必需)插件配置参数定义, 可加入自定义校验函数
return {
    name = "record_request",
    fields = {
        {
            consumer = typedefs.no_consumer
        },
        {
            config = {
                type = "record",
                fields = {
                    {
                    header_name = { type = "string", required = true },
                    },

                },
            },
        },
    },
}
