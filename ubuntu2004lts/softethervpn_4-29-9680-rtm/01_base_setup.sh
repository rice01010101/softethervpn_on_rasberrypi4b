#! /bin/bash

apt-get update
apt-get upgrade
apt-get dist-upgrade

# 1.firewall
apt-get install ufw
ufw default deny
# ssh only private network
ufw allow from REPLACE_YOUR_CIDRBLOCK to any port 22
ufw allow 443/tcp
ufw enable

# 2.user
adduser REPLACE_YOUR_NEW_USERNAME
usermod -G ubuntu,adm,dialout,cdrom,sudo,audio,dip,video,plugdev,netdev,lxd REPLACE_YOUR_NEW_USERNAME
# usermod --expiredate 1 pi
passwd root

# 3.ssh
mkdir -m 700 /home/REPLACE_YOUR_NEW_USERNAME/.ssh
ssh-keygen -t rsa -N "" -f /home/REPLACE_YOUR_NEW_USERNAME/.ssh/authorized_keys
mv /home/REPLACE_YOUR_NEW_USERNAME/.ssh/id_rsa.pub /home/REPLACE_YOUR_NEW_USERNAME/.ssh/authorized_keys
chmod 600 /home/REPLACE_YOUR_NEW_USERNAME/.ssh/authorized_keys
chown -R REPLACE_YOUR_NEW_USERNAME:REPLACE_YOUR_NEW_USERNAME /home/REPLACE_YOUR_NEW_USERNAME/.ssh
echo "\n\n finished.\n download your keys /home/REPLACE_YOUR_NEW_USERNAME/.ssh/id_rsa, after remove."

# 4.ssh advance
sed -i -e '1i #### override start\nPasswordAuthentication no\nPermitRootLogin no\nRSAAuthentication yes\nPubkeyAuthentication yes\nAuthorizedKeysFile %h/.ssh/authorized_keys\nPort 22\nUsePAM no\nChallengeResponseAuthentication no\nLoginGraceTime 120\n####override end' /etc/ssh/sshd_config
systemctl restart ssh