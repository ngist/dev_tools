# Overview
Sets up a simple DDNS service that runs once at boot, and sets IPv4 and IPv6 addresses in route53(aws)

To install:
```
git clone git@github.com:ngist/dev_tools.git
sudo ./dev_tools/ddns/install.sh mydomain.example.com AWS_ZONE_ID
```
