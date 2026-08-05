#!/bin/bash
DOMAIN=kmip.$ROOT_DOMAIN
IP4=`curl -4 ipv4.icanhazip.com`
IP6=`curl -6 ipv6.icanhazip.com`
cat <<EOF >/home/ec2-user/change_set.json
{
  "Comment": "Add record to point to EC2 instance",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$IP4"
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN",
        "Type": "AAAA",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$IP6"
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///home/ec2-user/change_set.json
