# Итоговая схема
Итоговая схема в файле "Scheme.drawio" на вкладке "Final Scheme"
# Итоговое приложение
## Развертывание
### "Автоматизированный" Shell-скрипт
Для развертывания в Docker выполнить в консоли:
```shell
./sharding-repl-cache/init-with-sharding-repl_cache.sh
```

> [!NOTE]
> Альтернатив скрипту, если по какой-то причине не запускается
###  Последовательность команд
#### Развертывание приложений в Docker
```shell
docker compose up -d
```
#### Доконфигурирование конфигурации и шардов MongoDB
```shell
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
```
#### Доконфигурирование mongos роутеров MongoDB
```shell
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
```
#### Наполнение MongoDB данными
```shell
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
```
## Проверка распределения данных по шардам и общее количество
```shell
./sharding-repl-cache/check-count.sh
```
## Проверка приложения
### Общее _(шарды/реплики)_
Перейти по ссылке http://localhost:8080/docs#/default/root__get
### Кэширование
Перейти по ссылке http://localhost:8080/docs#/default/list_users__collection_name__users_get и выполнить, передав helloDoc в collection_name
# Задания по этапам
# Task 1
Файл "Scheme.drawio" на вкладке "Progress", Шаг 1-3
# Task 2
Задание 2 в папке "mongo-sharding" со своим README.md
# Task 3
Задание 3 в папке "mongo-sharding-repl" со своим README.md
# Task 4
Задание 4 в папке "sharding-repl-cache" со своим README.md
# Task 5
Файл "Scheme.drawio" на вкладке "Progress", Шаг 4
# Task 6
Файл "Scheme.drawio" на вкладке "Progress", Шаг 5