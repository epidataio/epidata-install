EpiData Installation
=====================
Installation and launch scripts for setting up a standalone instance of EpiData

Docker Container
-----------------
The epidata-community docker image is available as a stand-alone package with all code and required components. To build and start a docker container, simply execute the command shown below (replacing 'epidata123' with a custom token):  
docker run -p 443:443 -it -e token=epidata123 epidataio/epidata-community:0.10.0

Install Scripts
----------------
- Launch a server with the following settings:
    - Ubuntu 14.04
    - memory of 8GB or larger
    - root storage of 30GB or larger

- Clone epidata-install to ubuntu user's home directory (/home/ubuntu).

- Install and Launch Application:
    - cd to /home/ubuntu/epidata-install/scripts folder
    - Specify GitHub user ID for 'DefaultUser' in epidata-install/scripts/subscripts/applicationStart_01.sh and epidata/play/app/providers/DemoProvider.scala. To find GitHub user ID for a user, visit https://caius.github.io/github_id/
    - Run scripts 1_xx through 6_xx in sequence
