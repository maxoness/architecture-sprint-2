#!/bin/bash

echo ---------  Document count in shard1-1 \(Master\) ------ 

# db.printReplicationInfo();
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo ---------  Document count in shard1-3 \(Slave\) ------ 

# db.printSecondaryReplicationInfo();
docker compose exec -T shard1-3 mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF


echo --------- Document count in shard2-1 \(Master\) ------ 

# db.printReplicationInfo();
docker compose exec -T shard2-1 mongosh --port 27022 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo ---------  Document count in shard2-2 \(Slave\) ------ 

# db.printSecondaryReplicationInfo();
docker compose exec -T shard2-2 mongosh --port 27023 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo --------- Document count in mongos_router1 --------- 

# db.printShardingStatus();
docker compose exec -T mongos_router1 mongosh --port 27025 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo --------- Document count in mongos_router2 --------- 

# db.printShardingStatus();
docker compose exec -T mongos_router2 mongosh --port 27021 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
