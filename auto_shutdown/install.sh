#!/bin/bash

# Installs the auto_shutdown.sh script to /opt and installs the associated systemctl service and timer.
src_dir=`dirname "$0"`

echo "Installing auto_shutdown.service..."
mkdir -p /opt
cp $src_dir/auto_shutdown.sh /opt/auto_shutdown.sh
cp $src_dir/auto_shutdown.service /etc/systemd/system/auto_shutdown.service
cp $src_dir/auto_shutdown.timer /etc/systemd/system/auto_shutdown.timer

echo "Enabling auto_shutdown service..."
systemctl daemon-reload
systemctl enable auto_shutdown.timer
systemctl start auto_shutdown.timer

# Disconnect unresponsive SSH sessions to avoid server staying up when it shouldn't.
echo "Setting up SSH daemon to terminate unresponsive SSH sessions after 15minutes..."
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/g' /etc/ssh/sshd_config

echo "Reloading sshd.service..."
systemctl reload sshd.service

