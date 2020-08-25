#! /bin/bash

readonly CIDR='REPLACE_YOUR_CIDR' # e.g.192.168.1.0/24
readonly NEW_SERVER_USERNAME='REPLACE_NEW_SERVER_USERNAME' # e.g.johndoe

apt-get update
apt-get upgrade
apt-get dist-upgrade

# 1.firewall
apt-get install ufw
ufw default deny
# ssh only private network
ufw allow from ${CIDR} to any port 22
ufw allow 443/tcp
ufw enable

# 2.user
adduser ${NEW_SERVER_USERNAME}
usermod -G ubuntu,adm,dialout,cdrom,sudo,audio,dip,video,plugdev,netdev,lxd ${NEW_SERVER_USERNAME}
passwd root

# 3.ssh
mkdir -m 700 /home/${NEW_SERVER_USERNAME}/.ssh
ssh-keygen -t rsa -N "" -f /home/${NEW_SERVER_USERNAME}/.ssh/authorized_keys
mv /home/${NEW_SERVER_USERNAME}/.ssh/id_rsa.pub /home/${NEW_SERVER_USERNAME}/.ssh/authorized_keys
chmod 600 /home/${NEW_SERVER_USERNAME}/.ssh/authorized_keys
chown -R ${NEW_SERVER_USERNAME}:${NEW_SERVER_USERNAME} /home/${NEW_SERVER_USERNAME}/.ssh
echo -e "##################################################\ndownload your keys /home/${NEW_SERVER_USERNAME}/.ssh/id_rsa, after remove.\n##################################################"

# 4.ssh advance
sed -i -e '1i #### override start\nPasswordAuthentication no\nPermitRootLogin no\nRSAAuthentication yes\nPubkeyAuthentication yes\nAuthorizedKeysFile %h/.ssh/authorized_keys\nPort 22\nUsePAM no\nChallengeResponseAuthentication no\nLoginGraceTime 120\n####override end' /etc/ssh/sshd_config
systemctl restart ssh