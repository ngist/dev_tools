#!/bin/bash
# Checks if the specified user has been logged in within last hour and shutsdown the computer if not.

user=$1

if [ -z $user ]; then
    echo "Usage $0 [username]"
    echo "Username must be provided, ussually ec2-user on aws"
    exit 1
fi

hour_ago="$(date --date='1 hour ago' '+%Y-%m-%d %H:%M:%S')"
timestamp_hour_ago=$(date --date='1 hour ago' +%s)

# Check for recent boot
booted_within_last_hour=$(last --since "$hour_ago" | grep reboot)

# Checks for ssh sessions
was_logged_in_hour_ago=$(last --present "$hour_ago" | grep $user)
has_logged_in_within_last_hour=$(last --since "$hour_ago" | grep $user)

# Checks for vscode sessions
active_vscode_session=$(lsof -i | grep $user | grep ESTABLISHED)
last_activity_vscode=$(du -sh --time /home/$user/.vscode-server | cut -f 2)
if test "$last_activity_vscode"; then
    last_activity_vscode=$(date -d "$last_activity_code" +%s)
else
    last_activity_vscode=0
fi

if test "$was_logged_in_hour_ago"; then
    echo $was_logged_in_hour_ago
    echo "User was logged in an hour ago or less... staying alive"
elif test "$has_logged_in_within_last_hour"; then
    echo $has_logged_in_within_last_hour
    echo "User logged in within the last hour... staying alive"
elif test "$active_vscode_session"; then
    echo $active_vscode_session
    echo "Active VSCODE session detected... staying alive"
elif (( $last_activity_vscode > $timestamp_hour_ago )); then
    echo "$last_activity_vscode > $timestamp_hour_ago"
    echo "VSCODE session detected within last hour... staying alive"
elif test "$booted_within_last_hour"; then
    echo $booted_within_last_hour
    echo "Instance booted within the last hour... staying alive"
else
    echo "No active user in last hour shutting down..."
    shutdown -h now
fi
