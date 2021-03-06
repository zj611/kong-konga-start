-- local crud = require "kong.api.crud_helpers"
local crud = require "kong.api.endpoints"
local utils = require "kong.tools.utils"

local ngx_error = ngx.ERR
local ngx_log = ngx.log

return {
    ["/consumers/:username_or_id/key-auth/"] = {
        before = function(self, dao_factory, helpers)
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
            self.params.consumer_id = self.consumer.id
        end,

        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.keyauth_credentials)
        end,

        PUT = function(self, dao_factory)
            crud.put(self.params, dao_factory.keyauth_credentials)
        end,

        POST = function(self, dao_factory)
            if self.params.key ==nil then
                self.params.key = self.consumer.id .. "--" .. utils.random_string()
            end
            crud.post(self.params, dao_factory.keyauth_credentials)
        end
    },
    ["/consumers/:username_or_id/key-auth/:credential_key_or_id"] = {
        before = function(self, dao_factory, helpers)
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
            self.params.consumer_id = self.consumer.id

            local credentials, err = crud.find_by_id_or_field(
                    dao_factory.keyauth_credentials,
                    { consumer_id = self.params.consumer_id },
                    ngx.unescape_uri(self.params.credential_key_or_id),
                    "key"
            )

            if err then
                return helpers.yield_error(err)
            elseif next(credentials) == nil then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end
            self.params.credential_key_or_id = nil

            self.keyauth_credential = credentials[1]
        end,

        GET = function(self, dao_factory, helpers)
            return helpers.responses.send_HTTP_OK(self.keyauth_credential)
        end,

        PATCH = function(self, dao_factory)
            crud.patch(self.params, dao_factory.keyauth_credentials, self.keyauth_credential)
        end,

        DELETE = function(self, dao_factory)
            crud.delete(self.keyauth_credential, dao_factory.keyauth_credentials)
        end
    },
    ["/key-auths/"] = {
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.keyauth_credentials)
        end
    },
    ["/key-auths/:credential_key_or_id/consumer"] = {
        before = function(self, dao_factory, helpers)
            local credentials, err = crud.find_by_id_or_field(
                    dao_factory.keyauth_credentials,
                    {},
                    ngx.unescape_uri(self.params.credential_key_or_id),
                    "key"
            )

            if err then
                return helpers.yield_error(err)
            elseif next(credentials) == nil then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end

            self.params.credential_key_or_id = nil
            self.params.username_or_id = credentials[1].consumer_id
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
        end,

        GET = function(self, dao_factory, helpers)
            return helpers.responses.send_HTTP_OK(self.consumer)
        end
    },


    ["/key-auths/no_route/route/:route_id"] = {
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.keyauth_no_routes)
        end,
        POST = function(self, dao_factory)
            crud.post(self.params, dao_factory.keyauth_no_routes)
        end
    },
    ["/key-auths/no_route/:id"] = {
        before = function(self, dao_factory, helpers)
            local rows, err = crud.find_by_id_or_field(dao_factory.keyauth_no_routes, {},
                    self.params.id, "id")
            if err then
                return helpers.yield_error(err)
            end
            if err then
                return helpers.yield_error(err)
            elseif #rows == 0 then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end
            self.keyauth_no_route = rows[1]
        end,
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.keyauth_no_routes)
        end,
        PATCH = function(self, dao_factory, helpers)
            crud.patch(self.params, dao_factory.keyauth_no_routes, self.keyauth_no_route)
        end,
        DELETE = function(self, dao_factory)
            crud.delete(self.keyauth_no_route, dao_factory.keyauth_no_routes)
        end
    }

}
