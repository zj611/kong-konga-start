-- local crud = require "kong.api.crud_helpers"
local crud = require "kong.api.endpoints"

return {
    ["/consumers/:username_or_id/acls/"] = {
        before = function(self, dao_factory, helpers)
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
            self.params.consumer_id = self.consumer.id
        end,
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.acls)
        end,
        PUT = function(self, dao_factory)
            crud.put(self.params, dao_factory.acls)
        end,
        POST = function(self, dao_factory)
            crud.post(self.params, dao_factory.acls)
        end
    },
    ["/consumers/:username_or_id/acls/:group_or_id"] = {
        before = function(self, dao_factory, helpers)
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
            self.params.consumer_id = self.consumer.id

            local acls, err =
                crud.find_by_id_or_field(
                dao_factory.acls,
                {consumer_id = self.params.consumer_id},
                self.params.group_or_id,
                "group"
            )

            if err then
                return helpers.yield_error(err)
            elseif #acls == 0 then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end
            self.params.group_or_id = nil

            self.acl = acls[1]
        end,
        GET = function(self, dao_factory, helpers)
            return helpers.responses.send_HTTP_OK(self.acl)
        end,
        PATCH = function(self, dao_factory)
            crud.patch(self.params, dao_factory.acls, self.acl)
        end,
        DELETE = function(self, dao_factory)
            crud.delete(self.acl, dao_factory.acls)
        end
    },
    ["/acls"] = {
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.acls)
        end
    },
    ["/acls/:acl_id/consumer"] = {
        before = function(self, dao_factory, helpers)
            local filter_keys = {
                id = self.params.acl_id
            }

            local acls, err = dao_factory.acls:find_all(filter_keys)
            if err then
                return helpers.yield_error(err)
            elseif next(acls) == nil then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end

            self.params.acl_id = nil
            self.params.username_or_id = acls[1].consumer_id
            crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
        end,
        GET = function(self, dao_factory, helpers)
            return helpers.responses.send_HTTP_OK(self.consumer)
        end
    },
    ["/acls/no_route/route/:route_id"] = {
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.acls_no_routes)
        end,
        POST = function(self, dao_factory)
            crud.post(self.params, dao_factory.acls_no_routes)
        end
    },
    ["/acls/no_route/:id"] = {
        before = function(self, dao_factory, helpers)
            local rows, err = crud.find_by_id_or_field(dao_factory.acls_no_routes, {}, self.params.id, "id")
            if err then
                return helpers.yield_error(err)
            end
            if err then
                return helpers.yield_error(err)
            elseif #rows == 0 then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end
            self.acls_no_route = rows[1]
        end,
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.acls_no_routes)
        end,
        PATCH = function(self, dao_factory, helpers)
            crud.patch(self.params, dao_factory.acls_no_routes, self.acls_no_route)
        end,
        DELETE = function(self, dao_factory)
            crud.delete(self.acls_no_route, dao_factory.acls_no_routes)
        end
    }
}
