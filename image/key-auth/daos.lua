local utils = require "kong.tools.utils"

local singletons = require "kong.singletons"

local function check_route_id_exist(route_id)
    local entity, _, err_t = kong.db.routes:select({ id = route_id })
    if err_t then
        return false, "route id does not exist"
    end
    if not entity then
        return false, "route id does not exist"
    end
    return true
end


local SCHEMA = {
    primary_key = { "id" },
    table = "keyauth_credentials",
    cache_key = { "key" },
    fields = {
        id = { type = "id", dao_insert_value = true },
        created_at = { type = "timestamp", immutable = true, dao_insert_value = true },
        consumer_id = { type = "id", required = true, foreign = "consumers:id" },
        key = { type = "string", required = false, unique = true }
    },
}

local NO_ROUTE_SCHEMA = {
    primary_key = { "id" },
    table = "keyauth_no_routes",
    cache_key = { "route_id" },
    fields = {
        id = { type = "id", dao_insert_value = true },
        created_at = { type = "timestamp", dao_insert_value = true },
        route_id = { type = "id", required = true, func = check_route_id_exist }
    },
}

return {
    keyauth_credentials = SCHEMA,
    keyauth_no_routes = NO_ROUTE_SCHEMA

}
