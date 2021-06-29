#!/bin/sh

# Update Spark Environment Variables
export SPARK_HOME=/home/ubuntu/spark-2.1.0-bin-hadoop2.6
echo "$SPARK_HOME"
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo export SPARK_WORKER_CORES=\"50\" >> $SPARK_HOME/conf/spark-env.sh
echo export SPARK_WORKER_MEMORY=\"3g\" >> $SPARK_HOME/conf/spark-env.sh
echo export SPARK_WORKER_INSTANCES=\"1\" >> $SPARK_HOME/conf/spark-env.sh
echo export SPARK_EXECUTOR_MEMORY=\"1g\" >> $SPARK_HOME/conf/spark-env.sh

cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
echo spark.driver.extraJavaOptions -Dderby.system.home=/tmp/derby >> $SPARK_HOME/conf/spark-defaults.conf

echo "installing EpiData application"

# Install EpiData
git clone https://github.com/epidataio/epidata-community.git /home/ubuntu/epidata
cd /home/ubuntu/epidata
virtualenv --system-site-packages venv
cd ..

# Install Python 2 packages in vitual environment
cd /home/ubuntu/epidata
. venv/bin/activate
pip install --upgrade setuptools pip
pip install autopep8 'ipython[all]'==3.2.3 pandas==0.19.2 oauth2 terminado kafka-python==1.3.3

# Install virtual environment for Jupyter Console and Notebook
cd /home/ubuntu/epidata/jupyter
virtualenv --system-site-packages jenv
. jenv/bin/activate
pip install --upgrade setuptools cython pip
pip install jupyter==1.0.0 jupyter-console==5.1.0 notebook==5.0.0 'ipython[all]'==5.4.1
pip install -r /home/ubuntu/epidata-install/config/requirements.txt
mkdir -p /home/ubuntu/epidata/jupyter/jenv/share/jupyter/kernels/pyspark/
cp /home/ubuntu/epidata-install/config/kernel.json /home/ubuntu/epidata/jupyter/jenv/share/jupyter/kernels/pyspark/kernel.json


deactivate
cd /home/ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu/.local/

# set up Cassandra Config file
sed -i "/authenticator:/c\authenticator: PasswordAuthenticator" /home/ubuntu/apache-cassandra-2.2.9/conf/cassandra.yaml
sed -i "/authorizer:/c\authorizer: AllowAllAuthorizer" /home/ubuntu/apache-cassandra-2.2.9/conf/cassandra.yaml

# Start Cassandra
sudo cp /home/ubuntu/epidata-install/init_scripts/cassandra /etc/init.d/.
sudo chmod +x /etc/init.d/cassandra
sudo service cassandra start
sudo update-rc.d cassandra defaults
sleep 20

# Set up Cassandra password
/home/ubuntu/apache-cassandra-2.2.9/bin/cqlsh -u cassandra -p cassandra -e "ALTER USER cassandra WITH PASSWORD 'epidata'"
# "CREATE ROLE epidata WITH SUPERUSER = true AND LOGIN = true AND PASSWORD = 'epidata';"

# Start Zookeeper and Kafka
sudo cp /home/ubuntu/epidata-install/init_scripts/kafka /etc/init.d/.
sudo chmod +x /etc/init.d/kafka
sudo service kafka start
sudo update-rc.d kafka defaults

# Generate play secret key
/home/ubuntu/epidata-install/scripts/subscripts/key_gen.sh | while read key; do
sed -i "/application.secret=/c\application.secret=\"$key\"" /home/ubuntu/epidata/play/conf/application.conf
done

# Generate token
/home/ubuntu/epidata-install/scripts/subscripts/key_gen.sh | while read token; do
sed -i "/application.api.tokens=/c\application.api.tokens=[\"$token\"]" /home/ubuntu/epidata/play/conf/application.conf;
sed -i "/c.NotebookApp.token/c\c.NotebookApp.token = '$token'" /home/ubuntu/epidata/jupyter/config.py;
done

# End of Script
