#!/bin/bash

src_dir=`dirname "$0"`

mkdir -p /opt
cp $src_dir/ddns.sh /opt/ddns.sh
cp $src_dir/ddns.service /etc/systemd/system/ddns.service

systemctl daemon-reload
systemctl enable ddns.service
systemctl start ddns.service
