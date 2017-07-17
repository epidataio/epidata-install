#!/bin/sh

# Start Cassanda
echo "starting cassandra"
cd /home/ubuntu/apache-cassandra-2.2.9
screen -S cassandra -d -m  bash -c "bin/cassandra -f"

/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p cassandra -e "ALTER KEYSPACE epidata_development WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }"

# Specify GitHub ID for default user
export DEFAULT_USER_ID = ''

# Add authorized users to Cassandra Users table
echo "adding authorized users to database"
echo `pwd`
echo `which python`
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p cassandra -e "insert into epidata_development.users (id) values ($DEFAULT_USER_ID)"

# Start Apache Spark
echo "starting spark"
export LOCAL_HOST_IP='127.0.0.1'
export SPARK_HOME=/home/ubuntu/spark-2.1.0-bin-hadoop2.6
SPARK_LOCAL_IP=$LOCAL_HOST_IP SPARK_MASTER_HOST=$LOCAL_HOST_IP SPARK_MASTER_WEBUI_PORT=18080 $SPARK_HOME/sbin/start-master.sh
SPARK_LOCAL_IP=$LOCAL_HOST_IP  SPARK_WORKER_WEBUI_PORT=18081 $SPARK_HOME/sbin/start-slave.sh spark://$LOCAL_HOST_IP:7077 --host $LOCAL_HOST_IP


# Start Apache Kafka
cd /home/ubuntu/kafka_2.10-0.10.2.0
echo "starting Zookeper"
screen -S zookeeper -d -m  bash -c 'bin/zookeeper-server-start.sh config/zookeeper.properties'
# Wait for Zookeper to finish
sleep 10
echo "Starting Kafka"
screen -S kafka -d -m  bash -c 'bin/kafka-server-start.sh config/server.properties'
# Wait for Kafka to finish
sleep 10
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic measurement_keys
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic measurements

# Launch Play
echo "starting epidata-play compile and test"
cd /home/ubuntu/epidata
. venv/bin/activate
echo `pwd`
echo `which python`
sbt '++ 2.10.6 models/compile' 'play/compile' '++ 2.11.8 spark/compile' 'ipython/compile'
sbt "project ipython" build
sbt "project spark" assembly
sbt "project scripts" assembly
sbt '++ 2.10.6 play/test' '++ 2.11.8 spark/test' 'ipython/test'

echo "starting epidata-play in new screen session"
screen -S playapp -d -m  bash -c 'sbt "project play" run'

export SERVER_NAME=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
iteration=0
response=0
while [ $response -ne 200 -a $iteration -lt 6 ]; do
  iteration=`expr $iteration + 1`
  response=$(curl -k -s -o /dev/null -w %{http_code} https://$SERVER_NAME)
  echo iteration $iteration, response $response, server $SERVER_NAME
  sleep 5
done

# End of Script
