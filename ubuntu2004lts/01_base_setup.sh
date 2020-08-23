#! /bin/bash
sudo su

apt-get update
apt-get upgrade
apt-get dist-upgrade

# 1.firewall
apt-get install ufw
ufw default deny
# ssh only private network
ufw allow from 192.168.0.0/24 to any port 22
ufw allow 443
ufw enable

# 2.user
adduser johndoe
usermod -aG pi,adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio johndoe
usermod --expiredate 1 pi
passwd root

# 3.ssh
su - johndoe
sudo ssh-keygen -t rsa
sudo cat .ssh/id_rsa.pub >> .ssh/authorized_keys
sudo rm .ssh/id_rsa.pub
sudo chmod 600 .ssh/authorized_keys
echo download your keys .ssh/id_rsa