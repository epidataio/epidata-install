#!/bin/sh

exec 3>&1 1>>/home/ubuntu/install_02.log 2>&1

# Remove directories and files from previous installs
sudo rm -rf ~/tmp
sudo rm -f ~/*.log
