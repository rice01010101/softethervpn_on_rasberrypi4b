#! /bin/bash

# rasberry pi 4B with softethervpn4.29rtm

# 1.necessary package install
#   virtual bridge tool
apt-get install -y bridge-utils 
#   softetherVPN build tool
apt-get install -y build-essential libreadline-dev libssl-dev libncurses-dev libz-dev

# 2.install standard softetherVPN
#   setup virtual bridge
echo -e "network:\n    ethernets:\n        eth0:\n            dhcp4: false\n            dhcp6: false\n    bridges:\n        br0:\n            interfaces: [eth0]\n            dhcp4: false\n            dhcp6: false\n            addresses: [192.168.3.100/24]\n            gateway4: 192.168.3.1\n            nameservers:\n                addresses: [192.168.3.1]\n    renderer: networkd\n    version: 2" > /etc/netplan/99-user-init.yaml
#   install softetherVPN
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/archive/v4.29-9680-rtm.zip
cd SoftEtherVPN_Stable-4.29-9680-rtm
sed -i -e "10860 s/ret/false/2" src/Cedar/Server.c
./configure
sed -i -e "s/-m64//" Makefile
make
make install
#   daemon setup
echo -e "[Unit]\nDescription=SoftEther VPN Server\nAfter=network.target network-online.target\n\n[Service]\nExecStart=/usr/bin/vpnserver start\nExecStop=/usr/bin/vpnserver stop\n#ExecStartPost=/bin/sleep 10 ; brctl addif br0 tap_softether\nType=forking\nRestartSec=3s\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/vpnserver.service
systemctl start vpnserver
systemctl enable vpnserver

cd ../

# 3.softetherVPN admin password setup. if vpncmd error happen then reboot and retry.
echo "on cli, execute ServerPasswordSet."
/usr/bin/vpncmd