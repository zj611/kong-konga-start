docker run -it --rm --name gateway   \
        --network=kong-net \
		-v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/plugins/custom-uuid:/usr/local/share/lua/5.1/kong/plugins/custom-uuid \
		-v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/plugins/record_request:/usr/local/share/lua/5.1/kong/plugins/record_request \
		-v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/plugins/key-auth:/usr/local/share/lua/5.1/kong/plugins/key-auth \
		-v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/plugins/transform/transform_req.lua:/usr/local/share/lua/5.1/kong/transform_req.lua  \
		-v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/plugins/transform/nginx_kong.lua:/usr/local/share/lua/5.1/kong/templates/nginx_kong.lua \
		-e "KONG_DB_UPDATE_FREQUENCY=10" \
		-e "KONG_DATABASE=cassandra" \
		-e "KONG_CASSANDRA_CONTACT_POINTS=kong-data" \
		-e "KONG_CASSANDRA_PORT=9042" \
		-e "KONG_CASSANDRA_USERNAME=cassandra" \
		-e "KONG_CASSANDRA_PASSWORD=cassandra" \
		-e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
		-e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
		-e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
		-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
		-e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
		-e "KONG_ADMIN_LISTEN_SSL=0.0.0.0:8444" \
		-e "KONG_PLUGINS=bundled,custom-uuid,record_request" \
        -p 8000:8000 \
		-p 8443:8443 \
		-p 8001:8001 \
		-p 8444:8444 \
		-p 9542:9542 \
		kong:2.1.3-ubuntu 



		# -e "KONG_PLUGINS=bundled,custom-uuid,custom-http-apis,custom-hello-print" \

                #-e "KONG_PLUGINS=bundled,custom-uuid,custom-http-apis" \
                #kong:alpine
		# -e "KONG_CASSANDRA_KEYSPACE=kong" \
		# -e "KONG_CASSANDRA_KEYSPACE=gateway" \
		# -e "KONG_CASSANDRA_CONSISTENCY=ONE" \
		# -e "KONG_PLUGINS=bundled,custom-acl,custom-auth,custom-rule,custom-http-apis,custom-dispatch-svc" \
                # ccr.ccs.tencentyun.com/fccv/gateway:0.1.7		
