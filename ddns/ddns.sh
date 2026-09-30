#!/bin/bash
IP4=`curl -4 ipv4.icanhazip.com`
IP6=`curl -6 ipv6.icanhazip.com`

domains=($DOMAIN)
zone_ids=($ZONE_ID)

for i in "${!domains[@]}"
do
  domain=${domains[i]}
  zone_id=${zone_ids[i]}
  cat <<EOF >/opt/change_set.json
  {
    "Comment": "Add record to point to EC2 instance",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "$domain",
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
          "Name": "$domain",
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

  aws route53 change-resource-record-sets --hosted-zone-id $zone_id --change-batch file:///opt/change_set.json
done