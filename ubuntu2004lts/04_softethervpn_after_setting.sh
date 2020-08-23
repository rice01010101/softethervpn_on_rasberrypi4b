#! /bin/bash
sudo su

# virtual bridge
sed -i -e '9s:^#::' /etc/systemd/system/vpnserver.service
systemctl daemon-reload
systemctl restart vpnserver.service