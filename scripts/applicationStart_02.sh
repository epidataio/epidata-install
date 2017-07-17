#!/bin/sh

# Launch Jupyter Notebook
. /home/ubuntu/.profile
cd /home/ubuntu/epidata/jupyter
. jenv/bin/activate
echo `pwd`
echo `which python`
echo "Starting jupyter notebook in new screen session"
screen -S jupyter -d -m  bash -c './start_notebook.sh'

# End of Script
