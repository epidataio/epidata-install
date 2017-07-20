#!/bin/sh

# Update Cassandra Replication Strategy
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p cassandra -e "ALTER KEYSPACE epidata_development WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }"

# Add authorized users to Cassandra Users table
echo "adding authorized users to database"
echo `pwd`
echo `which python`
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p cassandra -e "insert into epidata_development.users (id) values ('DEFAULT_USER_ID')"

# Launch Jupyter Notebook
. /home/ubuntu/.profile
cd /home/ubuntu/epidata/jupyter
. jenv/bin/activate
echo `pwd`
echo `which python`
echo "Starting jupyter notebook in new screen session"
screen -S jupyter -d -m  bash -c './start_notebook.sh'

# End of Script
