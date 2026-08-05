#!/bin/bash
cp /tmp/dev_tools/ddns/ddns.sh /opt/ddns.sh
cp /tmp/dev_tools/ddns/ddns.service /etc/systemd/system/ddns.service
systemctl daemon-reload
systemctl enable ddns.service
systemctl start ddns.service
