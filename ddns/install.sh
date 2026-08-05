#!/bin/bash

src_dir=`dirname "$0"`
DOMAIN=$1
ZONE_ID=$2

mkdir -p /opt
cp $src_dir/ddns.sh /opt/ddns.sh
cp $src_dir/ddns.service /etc/systemd/system/ddns.service
mkdir -p /etc/systemd/system/ddns.service.d

# Configure service env variables
cat <<EOF >/etc/systemd/system/ddns.service.d/local.conf
[Service]
DOMAIN=$DOMAIN
ZONE_ID=$ZONE_ID
EOF

systemctl daemon-reload
systemctl enable ddns.service
systemctl start ddns.service
