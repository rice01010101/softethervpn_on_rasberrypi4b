#! /bin/bash
sudo su

# rasberry pi 4B with softethervpn4.29rtm

# 1.necessary package install
#   virtual bridge tool
apt-get install bridge-utils 
#   softetherVPN build tool
apt-get install build-essential libreadline-dev libssl-dev libncurses-dev libz-dev

# 2.install standard softetherVPN
#   setup virtual bridge
sed -e '$a # eth0\auto eth0\ iface eth0 inet manual\\# brg0\auto brg0\ iface brg0 inet manual\ bridge_ports eth0\ bridge_maxwait 10' /etc/network/interfaces
sed -e '$a # eth0\denyinterfaces eth0\\# brg0\interface brg0\static ip_address=192.168.0.200/24\static routers=192.168.0.1\static domain_name_servers=192.168.0.1' /etc/dhcpcd.conf
#   install softetherVPN
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-arm_eabi-32bit.tar.gz
tar xzvf softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-arm_eabi-32bit.tar.gz
cd vpnserver
make
echo 3 time input all 1
mv vpnserver /usr/local/vpnserver
chmod 600 /usr/local/vpnserver/*
chmod 700 /usr/local/vpnserver/vpncmd
chmod 700 /usr/local/vpnserver/vpnserver
#   daemon setup
touch /etc/systemd/system/vpnserver.service
sed -e '[Unit]\Description=SoftEther VPN Server\After=network.target network-online.target\\[Service]\ExecStart=/usr/local/vpnserver/vpnserver start\ExecStop=/usr/local/vpnserver/vpnserver stop\WorkingDirectory=/usr/local/vpnserver\#ExecStartPost=/bin/sleep 10 ; brctl addif brg0 tap_softethervpn\Type=forking\RestartSec=3s\\[Install]
WantedBy=multi-user.target' /etc/systemd/system/vpnserver.service
chmod 755 /etc/systemd/system/vpnserver.service
systemctl daemon-reload
systemctl enable vpnserver.service
systemctl start vpnserver.service
cd ../

# 3.build custom softetherVPN
#   get and unzip softetherVPN
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/archive/v4.29-9680-rtm.tar.gz
tar zxvf v4.29-9680-rtm.tar.gz
cd SoftEtherVPN_Stable-4.29-9680-rtm
#   delete src/Cedar/Server.c line 10857
sed -e "10857d" src/Cedar/Server.c
#   configure and build
./configure
make

# 4.replace softetherVPN binary
#   install directory /usr/local/vpnserver
systemctl stop vpnserver
cp -rp bin/vpnserver/vpnserver /usr/local/vpnserver
cp -rp bin/vpncmd/vpncmd /usr/local/vpnserver
cp -rp bin/vpncmd/hamcore.se2 /usr/local/vpnserver
systemctl start vpnserver

# 5.softetherVPN admin password
echo on cli, execute ServerPasswordSet
/usr/local/vpnserver/vpncmd