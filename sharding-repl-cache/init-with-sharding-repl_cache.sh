#!/bin/bash

###
# доконфигурируем шарды MongoDB
###

docker compose up -d

#sleep 5 seconds for shard service loading. Otherwise connections can be rejected
echo Sleeping 5 seconds for shard service loading. Otherwise connections can be rejected
sleep 5

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "ReplicaSet1",
      members: [
        { _id : 0, host : "shard1-1:27018" },
        { _id : 1, host : "shard1-2:27019" },
        { _id : 2, host : "shard1-3:27020" },
      ]
    }
);
EOF

docker compose exec -T shard2-1 mongosh --port 27022 --quiet <<EOF
rs.initiate(
    {
      _id : "ReplicaSet2",
      members: [
        { _id : 0, host : "shard2-1:27022" },
        { _id : 1, host : "shard2-2:27023" },
        { _id : 2, host : "shard2-3:27024" },
      ]
    }
);
EOF

#sleep 5 seconds for router service loading. Otherwise connections can be rejected
echo Sleeping 5 seconds for router service loading. Otherwise connections can be rejected
sleep 5

docker compose exec -T mongos_router1 mongosh --port 27025 --quiet <<EOF
sh.addShard( "ReplicaSet1/shard1-1:27018");
sh.addShard( "ReplicaSet1/shard1-2:27019");
sh.addShard( "ReplicaSet1/shard1-3:27020");

sh.addShard( "ReplicaSet2/shard2-1:27022");
sh.addShard( "ReplicaSet2/shard2-2:27023");
sh.addShard( "ReplicaSet2/shard2-3:27024");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" });
EOF

docker compose exec -T mongos_router2 mongosh --port 27021 --quiet <<EOF
sh.addShard( "ReplicaSet1/shard1-1:27018");
sh.addShard( "ReplicaSet1/shard1-2:27019");
sh.addShard( "ReplicaSet1/shard1-3:27020");

sh.addShard( "ReplicaSet2/shard2-1:27022");
sh.addShard( "ReplicaSet2/shard2-2:27023");
sh.addShard( "ReplicaSet2/shard2-3:27024");

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF