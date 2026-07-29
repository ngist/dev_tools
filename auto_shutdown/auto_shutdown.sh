#!/bin/bash
# Checks if the specified user has been logged in within last hour and shutsdown the computer if not.

user=$1

if [ -z $user ]; then
    echo "Usage $0 [username]"
    echo "Username must be provided, ussually ec2-user on aws"
    exit 1
fi

time="$(date --date='1 hour ago' '+%Y-%m-%d %H:%M:%S')"
was_logged_in_hour_ago=`last --present "$time" | grep $user`
has_logged_in_within_last_hour=`last --since "$time" | grep $user`

if test "$was_logged_in_hour_ago" != ""; then
    echo $was_logged_in_hour_ago
    echo "Active user detected in the last hour... staying alive"
elif test "$has_logged_in_within_last_hour"; then
    echo $has_logged_in_within_last_hour
    echo "Active user detected in the last hour... statying alive"
else
    echo "No active user in last hour shutting down..."
    shutdown -h now
fi
