#!/bin/bash
source ./config.sh
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl enable nginx
mkdir -p /var/www/$WEB_NAME
unzip $WEB_FILE -d /var/www/$WEB_NAME

cp ./nginx.conf.template ./nginx.conf.template.bak
sed -i "s|\#domain|${DOMAIN}|g" ./nginx.conf.template.bak
sed -i "s|\#cer|${DOMAIN_CER}|g" ./nginx.conf.template.bak
sed -i "s|\#key|${DOMAIN_KEY}|g" ./nginx.conf.template.bak
sed -i "s|\#web_name|${WEB_NAME}|g" ./nginx.conf.template.bak
sed -i "s|\#web_uri|${WEB_URI}|g" ./nginx.conf.template.bak
sed -i "s|\#web_port|${WEB_PORT}|g" ./nginx.conf.template.bak
sed -i "s|\#ws_uri|${WS_URI}|g" ./nginx.conf.template.bak
sed -i "s|\#ws_port|${WS_PORT}|g" ./nginx.conf.template.bak

mv ./nginx.conf.template.bak /etc/nginx/nginx.conf
chmod 666 /etc/nginx/nginx.conf
sudo systemctl start nginx