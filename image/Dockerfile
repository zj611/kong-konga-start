FROM kong:alpine
MAINTAINER zj

USER root

# RUN apk update \
#     && apk upgrade \
#     && apk add  ca-certificates

# RUN apk add curl bash tree tzdata \
#     && cp -r -f /usr/share/zoneinfo/Hongkong /etc/localtime

ADD . /gateway/

# /usr/local/share/lua/5.1/kong/plugins/jwt/daos.lua:3
# RUN cp -R /Users/junzhang/Documents/code/kong_fccv/cassandra/image/custom-uuid /usr/local/share/lua/5.1/kong/plugins 


# COPY ./custom-uuid/ /usr/local/share/lua/5.1/kong/plugins 
# COPY ./custom-http-apis/  /usr/local/share/lua/5.1/kong/plugins

RUN cp -R /gateway/custom-http-apis  /usr/local/share/lua/5.1/kong/plugins \
    && cp -R /gateway/custom-uuid   /usr/local/share/lua/5.1/kong/plugins \
	&& cp -R /gateway/custom-hello-print   /usr/local/share/lua/5.1/kong/plugins \
	&& cp -R /gateway/transform/transform_req.lua  /usr/local/share/lua/5.1/kong/ \
	&& cp /gateway/templates/nginx_kong.lua /usr/local/share/lua/5.1/kong/templates/nginx_kong.lua  
	# && rm -r /usr/local/share/lua/5.1/kong/plugins/acl \
	# && cp -R /gateway/acl/  /usr/local/share/lua/5.1/kong/plugins/acl/ \
	# && rm -r /usr/local/share/lua/5.1/kong/plugins/key-auth \
	# && cp -R /gateway/key-auth  /usr/local/share/lua/5.1/kong/plugins \
	# && cp /gateway/public.lua  /usr/local/share/lua/5.1/kong/tools/



	# && cp -R /gateway/acl/  /usr/local/share/lua/5.1/kong/plugins/ \
	# && cp -R /gateway/key-auth  /usr/local/share/lua/5.1/kong/plugins 
    # && cp /gateway/responses.lua /usr/local/share/lua/5.1/kong/tools/responses.lua \
	# && cp /gateway/errors.lua  /usr/local/share/lua/5.1/kong/dao/errors.lua
	# && cp -R /gateway/acl/  /usr/local/share/lua/5.1/kong/plugins/acl/ 
	
	
	# 	&& cp -R /gateway/lib/kong  /usr/local/share/lua/5.1/ \


	

                      
#  KONG_PLUGINS: bundled,custom-acl,custom-auth,custom-rule,custom-http-apis,custom-dispatch-svc 
# cp -R /gateway/lib/kong  /usr/local/share/lua/5.1/ \
# 	&& cp -R /gateway/src/transform/transform_req.lua  /usr/local/share/lua/5.1/kong/
	# && cp -R /gateway/lib/vender/evp.lua /usr/local/share/lua/5.1/resty/ \
	# && cp -R /gateway/lib/vender/hmac.lua /usr/local/share/lua/5.1/resty/ \
	# && cp -R /gateway/lib/vender/jwt.lua /usr/local/share/lua/5.1/resty/ \
	# && cp -R /gateway/lib/vender/kafka /usr/local/share/lua/5.1/resty/ \
	# && cp -R /gateway/lib/vender/jwt-validators.lua /usr/local/share/lua/5.1/resty/ \
	# && cp -R /gateway/lib/vender/md5.lua /usr/local/share/lua/5.1/resty/ \

	# && cp -R /gateway/images/gateway/templates /usr/local/share/lua/5.1/kong/ \

	# && cp -R /gateway/src/acl  /usr/local/share/lua/5.1/kong/plugins \
	# && cp -R /gateway/src/custom-acl  /usr/local/share/lua/5.1/kong/plugins \
	# && cp -R /gateway/src/custom-auth /usr/local/share/lua/5.1/kong/plugins \
	# && cp -R /gateway/src/custom-rule  /usr/local/share/lua/5.1/kong/plugins \
	# && cp -R /gateway/src/key-auth  /usr/local/share/lua/5.1/kong/plugins \
    # && cp -R /gateway/src/custom-http-apis  /usr/local/share/lua/5.1/kong/plugins \
	# && cp -R /gateway/src/custom-dispatch-svc /usr/local/share/lua/5.1/kong/plugins \


COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# ENTRYPOINT ["/docker-entrypoint.sh"]

# CMD ["kong" "docker-start"]

