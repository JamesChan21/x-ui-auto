#!/bin/bash
source ./config.sh

curl --request POST \
  --url https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records \
  --header 'Content-Type: application/json' \
  --header 'X-Auth-Email: '${CF_EMAIL} \
  --header 'X-Auth-KEY: '${CF_API_ID} \
  --data "{\"type\":\"A\",\"name\":\"${DOMAIN}\",\"content\":\"${WEB_IP}\",\"ttl\":1,\"proxied\":true}"