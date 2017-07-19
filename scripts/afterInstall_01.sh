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
sbt "project spark" assembly
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
mkdir ./jenv/share/jupyter/kernels/pyspark/
cp /home/ubuntu/epidata-install/config/kernel.json ~/epidata/jupyter/jenv/share/jupyter/kernels/pyspark/kernel.json
pip install --upgrade setuptools cython pip
pip install jupyter==1.0.0 jupyter-console==5.1.0 notebook==5.0.0 'ipython[all]'==5.4.1
pip install -r /home/ubuntu/epidata-install/config/requirements.txt

deactivate
cd /home/ubuntu

#export JUPYTER_CONFIG_DIR=/home/ubuntu/test/.jupyter
#sudo chown -R ubuntu:ubuntu /home/ubuntu/.local/

# End of Script

