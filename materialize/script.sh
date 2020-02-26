confluent local start

curl -H 'Content-Type: application/json' localhost:8083/connectors --data '{
  "name": "psql-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "localhost",
    "database.port": "5432",
    "database.user": "debezium",
    "database.password": "debezium",
    "database.dbname" : "tpch",
    "database.server.name": "tpch",
    "plugin.name": "pgoutput",
    "slot.name" : "tester",
    "database.history.kafka.bootstrap.servers": "localhost:9092",
    "database.history.kafka.topic": "tpch-history"
  }
}'

kafka-avro-console-consumer --from-beginning --bootstrap-server localhost:9092 --topic tpch.tpch.sample

cd /usr/bin/ && materialized

cd /usr/bin/
source /home/elango/doc/developer/assets/demo/utils.sh
mtrlz-shell