#!/bin/sh

# Remove directories and files from previous installs
sudo rm -rf ~/tmp
sudo rm -f ~/*.log

sudo ./install_required_components.sh 1>>/home/ubuntu/install_01.log 2>&1

