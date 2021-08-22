docker run --restart always \
     -d \
     --name kong-data  \
     --network=kong-net \
     -v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/cassandra.yaml:/etc/cassandra/cassandra.yaml \
     -v /Users/junzhang/Documents/code/kong_fccv/cassandra-kong/data:/var/lib/cassandra \
     -p 7000:7000 \
     -p 9042:9042 \
     cassandra:3
#     ccr.ccs.tencentyun.com/fccv/cassandra:3
# -v /Users/junzhang/Documents/code/kong_fccv/cassandra/cassandra.yaml:/etc/cassandra/cassandra.yaml \
#-e CASSANDRA_BROADCAST_ADDRESS=10.1.0.32 \
