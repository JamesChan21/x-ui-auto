#!/bin/bash

# Nginx Engine Configuration
DOMAIN="xxx.xxx.xxx"
WEB_FILE="xxx.zip"
WEB_NAME=$(echo "$WEB_FILE" | cut -d'.' -f1)
WEB_URI="/xxx"
WS_URI="/xxx"
WS_PORT="45625"

# Cert Configuration
CERT_PATH="/etc/ssl/certs/"
DOMAIN_CER="${CERT_PATH}${DOMAIN}.cer"
DOMAIN_KEY="${CERT_PATH}${DOMAIN}.key"
CF_EMAIL="xxxxxxxxxxx@qq.com"
CF_API_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
CF_ZONE_ID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# x-ui-panal Configuration
# USERNAME="admin"
# PASSWORD="admin"
WEB_IP=$(curl --ipv4 ifconfig.co)
WEB_PORT="54333"

# smtp Configuration
SMTP_SERVER=""
SMTP_PORT=""
SMTP_USERNAME=""
SMTP_PASSWORD=""
SENDER_EMAIL=""
RECEIVER_EMAIL=""