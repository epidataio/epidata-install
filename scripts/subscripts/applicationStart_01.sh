#!/bin/sh

# Start Apache Spark
echo "starting spark"
export LOCAL_HOST_IP='127.0.0.1'
export SPARK_HOME=/home/ubuntu/spark-2.1.0-bin-hadoop2.6
SPARK_LOCAL_IP=$LOCAL_HOST_IP SPARK_MASTER_HOST=$LOCAL_HOST_IP SPARK_MASTER_WEBUI_PORT=18080 $SPARK_HOME/sbin/start-master.sh
SPARK_LOCAL_IP=$LOCAL_HOST_IP  SPARK_WORKER_WEBUI_PORT=18081 $SPARK_HOME/sbin/start-slave.sh spark://$LOCAL_HOST_IP:7077 --host $LOCAL_HOST_IP

# Create Kafka Topic
/home/ubuntu/kafka_2.10-0.10.2.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic measurement_keys
/home/ubuntu/kafka_2.10-0.10.2.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic measurements

# Launch Play
cd /home/ubuntu/epidata-install/bin/
./epidata build
./epidata start

export SERVER_NAME=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
iteration=0
response=0
while [ $response -ne 200 -a $iteration -lt 6 ]; do
  iteration=`expr $iteration + 1`
  response=$(curl -k -s -o /dev/null -w %{http_code} https://$SERVER_NAME)
  echo iteration $iteration, response $response, server $SERVER_NAME
  sleep 5
done

# Set up Cassandra keyspace replication and default user
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p epidata -e "ALTER KEYSPACE epidata_development WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }"
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p epidata -e "insert into epidata_development.users (id) values ('DefaultUser')"

# End of Script
