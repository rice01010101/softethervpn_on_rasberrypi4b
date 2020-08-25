#! /bin/bash

# after softethervpn GUI setting, virtual bridge enable
sed -i -e "9 s/#//" /etc/systemd/system/vpnserver.service
systemctl daemon-reload
systemctl restart vpnserver