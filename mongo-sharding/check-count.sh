#!/bin/bash

echo ---------  Document count in shard1 ------ 

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF


echo --------- Document count in shard2 ------ 

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

echo --------- Document count in mongos_router1 --------- 

docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF
