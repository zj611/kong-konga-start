docker run -it --rm  \
                --network=kong-net \
                -e "KONG_DATABASE=cassandra" \
		-e "KONG_CASSANDRA_CONTACT_POINTS=kong-data" \
		-e "KONG_CASSANDRA_PORT=9042" \
		-e "KONG_CASSANDRA_USERNAME=gateway" \
		-e "KONG_CASSANDRA_PASSWORD=gateway123" \
                -e "KONG_PLUGINS=bundled,custom-uuid,record_request" \
                kong:2.1.3-ubuntu kong migrations up
                # kong_fccv:dev kong migrations up
                #kong_fccv:dev kong migrations up
                #kong:alpine kong migrations up
                #kong:alpine kong migrations bootstrap

        #   -e "KONG_PLUGINS=bundled,custom-uuid,custom-http-apis,custom-hello-print" \

#     -e "KONG_CASSANDRA_KEYSPACE=gateway" \
#                 -e "KONG_CASSANDRA_REPL_FACTOR=3" \
#                 -e "KONG_CASSANDRA_CONSISTENCY=ONE" \
	       # -e "KONG_PLUGINS=bundled,custom-acl,custom-auth,custom-rule,custom-http-apis,custom-dispatch-svc" \
           
