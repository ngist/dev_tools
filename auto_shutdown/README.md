# Overview
This is a simple auto shutdown script and associated systemctl service/timer that can be used to automatically 
shutdown cloud machines when not in use. This is helpful if you want to setup an ec2 dev instance then wander 
off after a few hours, you'll still get billed for EBS and associated services but not the on-demand instance itself.

# How it works
It looks to see if ec2-user has been logged in within the last hour, if not it shuts the machine down.

To install:
```
git clone git@github.com:ngist/dev_tools.git
sudo ./dev_tools/auto_shutdown/install.sh
```
