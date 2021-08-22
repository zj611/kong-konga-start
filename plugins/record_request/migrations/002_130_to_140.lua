local operations = require "kong.db.migrations.operations.200_to_210"

local plugin_entities = {
  {
    name = "record_request",
    primary_key = "id",
    -- uniques = {"key"},
    -- fks = {{name = "consumer", reference = "consumers", on_delete = "cascade"}},--主外键关系中，级联删除，即删除主表数据会自动删除从表数据
  }
}

return operations.ws_migrate_plugin(plugin_entities)
