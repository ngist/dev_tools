#!/bin/bash
# Checks if the specified user has been logged in within last hour and shutsdown the computer if not.

user=$1

if [ -z $user ]; then
    echo "Usage $0 [username]"
    echo "Username must be provided, ussually ec2-user on aws"
    exit 1
fi

time="$(date --date='1 hour ago' '+%Y-%m-%d %H:%M:%S')"
was_logged_in_hour_ago=$(last --present "$time" | grep $user)
has_logged_in_within_last_hour=$(last --since "$time" | grep $user)
booted_within_last_hour=$(last --since "$time" | grep reboot)
active_vscode_session=$(lsof -i | grep $user | grep ESTABLISHED)
last_activity_vscode=$(du -sh --time ~/.vscode-server | cut -f 2 | date +%s)
timestamp_hour_ago=$(date --date='1 hour ago' +%s)


if test "$was_logged_in_hour_ago" != ""; then
    echo $was_logged_in_hour_ago
    echo "User was logged in an hour ago or less... staying alive"
elif test "$has_logged_in_within_last_hour" != ""; then
    echo $has_logged_in_within_last_hour
    echo "User logged in within the last hour... staying alive"
elif test "$active_vscode_session" != ""; then
    echo $active_vscode_session
    echo "Active VSCODE session detected... staying alive"
elif test "$last_activity_vscode" > "$timestamp_hour_ago"; then
    echo "$last_activity_vscode > $timestamp_hour_ago"
    echo "VSCODE session detected within last hour... staying alive"
elif test "$booted_within_last_hour" != ""; then
    echo $booted_within_last_hour
    echo "Instance booted within the last hour... staying alive"
else
    echo "No active user in last hour shutting down..."
    shutdown -h now
fi
