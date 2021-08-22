---
--- Created by linhuali.
--- DateTime: 2018/8/2 下午2:42
---

local ngx = ngx

local Transform_req = {}

function Transform_req.init()
    local arg = ngx.req.get_uri_args()
    if arg then
        if arg["flag"] and arg["flag"] == "download" then
            if not arg["token"] then
                ngx.status = 423
                ngx.say("token err")
            end
            if not arg["apikey"] then
                ngx.status = 423
                ngx.say("apikey err")
            end
            ngx.req.set_header("token", arg["token"])
        end
    end
    local headers = ngx.req.get_headers()
    local server_name = headers and (headers["Server-name"] or headers["server-name"])
    if server_name then
        ngx.req.set_header("host", server_name)
    end
end

return Transform_req