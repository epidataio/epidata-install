#!/bin/sh

# Scipt for installing required components for EpiData

# Install Java
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
apt-get install --yes --force-yes oracle-java8-installer
echo export JAVA_HOME=/usr/lib/jvm/java-8-oracle >> /etc/environment

# Install wget
apt-get install wget

# scala install
apt-get remove scala-library scala
wget -P /home/ubuntu -q www.scala-lang.org/files/archive/scala-2.11.8.deb
dpkg -i /home/ubuntu/scala-2.11.8.deb
apt-get update
apt-get --yes --force-yes install scala

# Install sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
apt-get update
apt-get --yes --force-yes install sbt=0.13.6

# Install nginx
#sudo apt-get update
apt-get --yes --force-yes install nginx

# Install openssl
apt-get --yes --force-yes install openssl

# Install git
apt-get --yes --force-yes install git

# Install Cassandra 2.2.9 
wget -P /home/ubuntu/ -q  http://archive.apache.org/dist/cassandra/2.2.9//apache-cassandra-2.2.9-bin.tar.gz
chown ubuntu:ubuntu /home/ubuntu/apache-cassandra-2.2.9-bin.tar.gz
tar xzvf /home/ubuntu/apache-cassandra-2.2.9-bin.tar.gz  -C /home/ubuntu/
chown -R ubuntu:ubuntu /home/ubuntu/apache-cassandra-2.2.9

# Install Docker
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main >> /etc/apt/sources.list.d/docker.list
apt-get update
apt-get --yes --force-yes install docker-engine=1.9.1-0~trusty
usermod -aG docker ubuntu
service docker restart
sleep 10
echo export DOCKER_HOST_IP=`ifconfig docker0 | awk 'NR==2 {print $2}' | sed s/addr://` >> /home/ubuntu/.profile
. /home/ubuntu/.profile

# Install Spark 2.1.0
wget -P /home/ubuntu/ -q http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.6.tgz
chown ubuntu:ubuntu /home/ubuntu/spark-2.1.0-bin-hadoop2.6.tgz
tar xzvf /home/ubuntu/spark-2.1.0-bin-hadoop2.6.tgz -C /home/ubuntu/
chown -R ubuntu:ubuntu /home/ubuntu/spark-2.1.0-bin-hadoop2.6
echo export PATH=$PATH:/home/ubuntu/apache-cassandra-2.2.9/bin:/home/ubuntu/spark-2.1.0-bin-hadoop2.6/bin >> /home/ubuntu/.profile
echo export SPARK_HOME=/home/ubuntu/spark-2.1.0-bin-hadoop2.6  >> /home/ubuntu/.profile
echo export PYSPARK_PYTHON=/home/ubuntu/epidata/venv/bin/python >> /home/ubuntu/.profile
echo export PYTHONPATH=$PYTHONPATH:/home/ubuntu/spark-2.1.0-bin-hadoop2.6/python:/home/ubuntu/spark-2.1.0-bin-hadoop2.6/python/build:/home/ubuntu/spark-2.1.0-bin-hadoop2.6/python/lib/py4j-0.10.4-src.zip  >> /home/ubuntu/.profile
. /home/ubuntu/.profile

# Use the latest guava
cp /home/ubuntu/epidata-install/jars/guava-19.0.jar /home/ubuntu/spark-2.1.0-bin-hadoop2.6/jars/.
mv /home/ubuntu/spark-2.1.0-bin-hadoop2.6/jars/guava-14.0.1.jar /home/ubuntu/spark-2.1.0-bin-hadoop2.6/jars/guava-14.0.1.jar_

# Install Kafka
wget -P /home/ubuntu/ -q http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.10.2.0/kafka_2.10-0.10.2.0.tgz
tar xzvf /home/ubuntu/kafka_2.10-0.10.2.0.tgz -C /home/ubuntu/

# Install pip
apt-get --yes --force-yes install python-pip python-dev
apt-get install -y libblas-dev liblapack-dev
pip install virtualenv

# Install pip3
apt-get --yes --force-yes install python3-pip
pip3 install virtualenv

# Install jupyter notebook dependencies
sudo apt-get --yes --force-yes install npm nodejs-legacy
sudo npm install proptypes preact preact-compat
sudo rm -rf tmp # Clean up directory left by npm.

# Install autoenv.
git clone git://github.com/kennethreitz/autoenv.git /home/ubuntu/.autoenv
echo 'source /home/ubuntu/.autoenv/activate.sh' >> /home/ubuntu/.bashrc
. /home/ubuntu/.bashrc

# Configure system settings
echo 'root \t\t hard \t nofile \t 262144' >> /etc/security/limits.conf
echo 'root \t\t soft \t nofile \t 262144' >> /etc/security/limits.conf
echo '* \t\t hard \t nofile \t 262144' >> /etc/security/limits.conf
echo '* \t\t soft \t nofile \t 262144' >> /etc/security/limits.conf

# Generate key for local SSH access by Spark worker nodes
if [ -e '/home/ubuntu/.ssh/id_rsa' ]; then
  :
else
  ssh-keygen -f /home/ubuntu/.ssh/id_rsa -t rsa -N ''
  cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
fi

# Specify SSL certificate path
echo export AWS_SSL_CA_DIRECTORY="/etc/ssl/certs" >> /etc/environment

reboot

# End of Script

