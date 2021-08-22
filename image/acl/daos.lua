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
    primary_key = { "id" },
    table = "acls",
    cache_key = { "consumer_id" },
    fields = {
        id = { type = "id", dao_insert_value = true },
        created_at = { type = "timestamp", dao_insert_value = true },
        consumer_id = { type = "id", required = true, foreign = "consumers:id" },
        group = { type = "string", required = true, func = check_unique }
    },
}

local NO_ROUTE_SCHEMA = {
    primary_key = { "id" },
    table = "acls_no_routes",
    cache_key = { "route_id" },
    fields = {
        id = { type = "id", dao_insert_value = true },
        created_at = { type = "timestamp", dao_insert_value = true },
        route_id = { type = "id", required = true, func = check_route_id_exist }
    },
}

return {
    acls = SCHEMA,
    acls_no_routes = NO_ROUTE_SCHEMA
}
