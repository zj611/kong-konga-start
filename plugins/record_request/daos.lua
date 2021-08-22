local typedefs = require "kong.db.schema.typedefs"

return {
  record_request = {
    ttl = true,
    primary_key = { "id" },
    name = "record_request",
    -- endpoint_key = "key",
    -- cache_key = { "key" },
    -- workspaceable = true,
    admin_api_name = "record_request",
    admin_api_nested_name = "record_request_",
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },
      -- { consumer = { type = "foreign", reference = "consumers", required = true, on_delete = "cascade", }, },
      -- { key = { type = "string", required = false, unique = true, auto = true }, },
      -- { server_name = { type = "string", required = false, unique = false, auto = false }, },
      { ws_id = typedefs.uuid },
      { key = { type = "string"}, },
      { server_name = { type = "string"}, },
      -- { tags = typedefs.tags },
    },
  },
}

