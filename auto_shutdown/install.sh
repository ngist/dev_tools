#!/bin/bash

# Installs the auto_shutdown.sh script to /opt and installs the associated systemctl service and timer.
src_dir=`dirname "$0"`

mkdir -p /opt
cp $src_dir/auto_shutdown.sh /opt/auto_shutdown.sh
cp $src_dir/auto_shutdown.service /etc/systemd/system/auto_shutdown.service
cp $src_dir/auto_shutdown.timer /etc/systemd/system/auto_shutdown.timer

systemctl daemon-reload
systemctl enable auto_shutdown.timer
systemctl start auto_shutdown.timer
