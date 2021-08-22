local typedefs = require "kong.db.schema.typedefs"
local singletons = require "kong.singletons"


local function check_unique(group, acl)
  -- If dao required to make this work in integration tests when adding fixtures
  if singletons.db and acl.consumer_id and group then
      local res, err = singletons.db.acls:find_all { consumer_id = acl.consumer_id, group = group }
      if not err and #res > 0 then
          return false, "ACL group already exist for this consumer"
      elseif not err then
          return true
      end
  end
end

local function check_route_id_exist(route_id)
  local entity, _, err_t = singletons.db.routes:select({ id = route_id })
  if err_t then
      return false, "route id does not exist"
  end
  if not entity then
      return false, "route id does not exist"
  end
  return true
end




local SCHEMA = {
  acls = {
    dao = "kong.plugins.acl.acls",
    name = "acls",
    primary_key = { "id" },
    cache_key = { "consumer", "group" },
    workspaceable = true,
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },
      { consumer = { type = "foreign", reference = "consumers", required = true, on_delete = "cascade" }, },
      { group = { type = "string", required = true } },
      { tags  = typedefs.tags },
    },
  },
}

local NO_ROUTE_SCHEMA = {
  dao = "kong.plugins.acl.acls_no_routes",
  name = "acls_no_routes",
  primary_key = { "id" },
  -- table = "acls_no_routes",
  cache_key = { "route_id" },
  workspaceable = true,
  -- type = "record",
  fields = {
      {id = typedefs.uuid},
      {created_at = typedefs.auto_timestamp_s},
      -- { route_id = typedefs.uuid },
      {route_id = {type = "string", unique = true },},
      -- { route_id = {  typedefs.uuid, required = true, unique = true } }
      -- {route_id = { type = "id", required = true, func = check_route_id_exist }}
  },
}



return {
  acls = SCHEMA,
  acls_no_routes = NO_ROUTE_SCHEMA
}

