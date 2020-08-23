#! /bin/bash

sudo su

# 1.ssh advance
sed -e 'a$ PasswordAuthentication no\PermitRootLogin no\RSAAuthentication yes\PubkeyAuthentication yes\AuthorizedKeysFile %h/.ssh/authorized_keys\Port 22\UsePAM no\ChallengeResponseAuthentication no\LoginGraceTime 120' /etc/ssh/sshd_config
systemctl restart ssh
