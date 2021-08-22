local constants = require "kong.constants"
local tablex = require "pl.tablex"
local groups = require "kong.plugins.acl.groups"
local singletons = require "kong.singletons"


local setmetatable = setmetatable
local concat = table.concat
local error = error
local kong = kong


local EMPTY = tablex.readonly {}
local DENY = "DENY"
local ALLOW = "ALLOW"


local mt_cache = { __mode = "k" }
local config_cache = setmetatable({}, mt_cache)


local function get_to_be_blocked(config, groups, in_group)
  local to_be_blocked
  if config.type == DENY then
    to_be_blocked = in_group
  else
    to_be_blocked = not in_group
  end

  if to_be_blocked == false then
    -- we're allowed, convert 'false' to the header value, if needed
    -- if not needed, set dummy value to save mem for potential long strings
    to_be_blocked = config.hide_groups_header and "" or concat(groups, ", ")
  end

  return to_be_blocked
end


local ACLHandler = {}


ACLHandler.PRIORITY = 950
ACLHandler.VERSION = "0.1.0"



local function load_acls_into_memory(consumer_id)
  local results, err = singletons.db.acls:find_all { consumer_id = consumer_id }
  if err then
      return nil, err
  end
  return results
end

local function load_acls_no_route_into_memory(route_id)
  local results, err = singletons.db.acls_no_routes:find_all { route_id = route_id }
  if err then
      return nil, err
  end
  return results
end

local function valid_no_route(route_id)
  -- local entity, _, err_t = singletons.db.routes:select({ id = route_id })
  -- local entity, _, err_t = singletons.db.acls:select({ id = route_id })
  local cache_key_no_route = singletons.db.acls_no_routes:cache_key(route_id)
  local no_route, err = singletons.cache:get(cache_key_no_route, nil,
          load_acls_no_route_into_memory, route_id)
  if err then
      ngx_log(ngx_error, "get cache err")
      return false, route_id
  end

  if no_route == nil or next(no_route) == nil then
      ngx_log(ngx_error, "no route")
      return false, no_route
  end

  return true
end



function ACLHandler:access(conf)

  local ctx = ngx.ctx
  local route = ctx.route
  local route_id = route.id

  local ok, no_route = valid_no_route(route_id)
  if ok then
      return
  end

  -- simplify our plugins 'conf' table
  local config = config_cache[conf]
  if not config then
    local config_type = (conf.deny or EMPTY)[1] and DENY or ALLOW

    config = {
      hide_groups_header = conf.hide_groups_header,
      type = config_type,
      groups = config_type == DENY and conf.deny or conf.allow,
      cache = setmetatable({}, mt_cache),
    }

    config_cache[conf] = config
  end

  local to_be_blocked

  -- get the consumer/credentials
  local consumer_id = groups.get_current_consumer_id()
  if not consumer_id then
    local authenticated_groups = groups.get_authenticated_groups()
    if not authenticated_groups then
      if kong.client.get_credential() then
        return kong.response.error(403, "You cannot consume this service")
      end

      return kong.response.error(401)
    end

    local cache_key = singletons.db.acls:cache_key(consumer_id)
    local acls, err = singletons.cache:get(cache_key, nil,
            load_acls_into_memory, consumer_id)
    if err then
        -- return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
        return kong.response.error(500, "Internal server error")
    end
    if not acls then
        acls = EMPTY
    end



    local in_group = groups.group_in_groups(config.groups, authenticated_groups)
    to_be_blocked = get_to_be_blocked(config, authenticated_groups, in_group)

  else
    local credential = kong.client.get_credential()
    local authenticated_groups
    if not credential then
      -- authenticated groups overrides anonymous groups
      authenticated_groups = groups.get_authenticated_groups()
    end

    if authenticated_groups then
      consumer_id = nil

      local in_group = groups.group_in_groups(config.groups, authenticated_groups)
      to_be_blocked = get_to_be_blocked(config, authenticated_groups, in_group)

    else
      -- get the consumer groups, since we need those as cache-keys to make sure
      -- we invalidate properly if they change
      local consumer_groups, err = groups.get_consumer_groups(consumer_id)
       if err then
        return error(err)
      end

      if not consumer_groups then
        if config.type == DENY then
          consumer_groups = EMPTY

        else
          if credential then
            return kong.response.error(403, "You cannot consume this service")
          end

          return kong.response.error(401)
        end
      end

      -- 'to_be_blocked' is either 'true' if it's to be blocked, or the header
      -- value if it is to be passed
      to_be_blocked = config.cache[consumer_groups]
      if to_be_blocked == nil then
        local in_group = groups.consumer_in_groups(config.groups, consumer_groups)
        to_be_blocked = get_to_be_blocked(config, consumer_groups, in_group)

        -- update cache
        config.cache[consumer_groups] = to_be_blocked
      end
    end
  end

  if to_be_blocked == true then -- NOTE: we only catch the boolean here!
    return kong.response.error(403, "You cannot consume this service")
  end

  if not conf.hide_groups_header and to_be_blocked then
    kong.service.request.set_header(consumer_id and
                                    constants.HEADERS.CONSUMER_GROUPS or
                                    constants.HEADERS.AUTHENTICATED_GROUPS,
                                    to_be_blocked)
  end
end


return ACLHandler
