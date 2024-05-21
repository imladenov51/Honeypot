#!/bin/bash

# Launch the "database" honeypot
sudo lxc-create -n database -t download -- -d ubuntu -r focal -a amd64
sudo lxc-start -n database
sleep 10

# Fetch the internal IP and store it for routing
IP=$(sudo lxc-info -n database -iH)

# Install important binaries on the honeypot
sudo lxc-attach -n database -- bash -c "sudo apt-get update"
sudo lxc-attach -n database -- bash -c "sudo apt-get install openssh-server -y"
sleep 10
sudo lxc-attach -n database -- bash -c "sudo systemctl enable ssh --now"
sudo lxc-attach -n database -- bash -c "sudo apt-get install wget -y"
sleep 10
sudo lxc-attach -n database -- bash -c "sudo apt-get install mysql-server"
sleep 10
sudo lxc-attach -n database -- bash -c "sudo wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh"
sudo lxc-attach -n database -- bash -c "sudo chmod 755 install-snoopy.sh"
sudo lxc-attach -n database -- bash -c "sudo ./install-snoopy.sh stable"
sudo lxc-attach -n database -- bash -c "sudo rm -rf ./install-snoopy.* snoopy-*"

# Plant honey into the MySQL database and clear file
sudo cp ~/database.sql /var/lib/lxc/database/rootfs/database.sql
sudo lxc-attach -n database -- bash -c "sudo mysql < /database.sql"
sudo rm /var/lib/lxc/database/rootfs/database.sql

# Create directory for Snoopy logs
mkdir ~/snoopy_logs

# Setup network configurations
sudo ip addr add 172.30.250.121/16 brd + dev "eth0"
sudo iptables --table nat --insert POSTROUTING --source $IP --destination 0.0.0.0/0 --jump SNAT --to-source 172.30.250.121
sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination 172.30.250.121 --jump DNAT --to-destination $IP
# Insert MITM rule at the top of the iptables
sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination 172.30.250.121 --protocol tcp --dport 22 --jump DNAT --to-destination 127.0.0.1:64646

# Launch MITM server
sudo sysctl -w net.ipv4.conf.all.route_localnet=1
sudo npm install -g forever
mkdir ~/mitm_logs
sudo forever -a -l ~/mitm_logs/database.log start ~/MITM/mitm.js -n database -i $IP -p 64646 --auto-access --auto-access-fixed 3 --debug