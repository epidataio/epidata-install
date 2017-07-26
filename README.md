EpiData Installation
=====================
Installation and launch scripts for setting up a standalone instance of EpiData

Install Steps
--------------

- Launch a server with the following settings:
    - Ubuntu 14.04
    - memory of 8GB or larger
    - root storage of 30GB or larger

- Copy epidata-install contents to home folder. Home folder structure:
    - config
    - scripts

- Install Application:
    - cd to scripts folder
    - Run scripts 1_xx through 4_xx in sequence
    - Specify play application secret in epidata/play/conf/application.conf
    - Specify GitHub user ID for default user in applicationStart_02.sh and epidata/play/app/providers/DemoProvider.scala
    - Run scripts 5_xx through 7_xx in sequence
