#!/bin/bash

# Nginx Engine Configuration
SUB_DOMAIN="xxx.xxx.xxx"
SECOND_DOMAIN=$(echo "$SUB_DOMAIN" | sed 's/.*\.\([^.]*\.[^.]*\)$/\1/')

WEB_FILE="xxx.zip"
WEB_NAME=$(echo "$WEB_FILE" | cut -d'.' -f1)

WEB_URI="/xxx"
WS_URI="/xxx"
WS_PORT="45625"

# Cert Configuration
CERT_PATH="/etc/ssl/certs/"
SECOND_DOMAIN_CER="$CERT_PATH$SECOND_DOMAIN.cer"
SECOND_DOMAIN_KEY="$CERT_PATH$SECOND_DOMAIN.key"

CF_EMAIL="xxxxxxxxxxx@qq.com"
CF_API_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# x-ui-panal Configuration
# USERNAME="admin"
# PASSWORD="admin"
WEB_PORT="54333"
