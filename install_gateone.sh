#!/bin/bash 
#
# Installs the GateOne HTML5 Terminal UI on EMR
#
# By Jacob Goren
#
# Available on private IP at port 10433 over HTTPS (SSL no valid, so browser will think it is phishing, Click through

sudo yum install git -y
sudo pip install tornado kerberos
sudo git clone https://github.com/liftoff/GateOne.git /home/hadoop/gateone
cd /home/hadoop/gateone
sudo python setup.py install
sudo nohup sh /home/hadoop/gateone/run_gateway.sh &
exit 0
