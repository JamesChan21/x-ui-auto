#!/bin/bash
source ./config.sh
setenforce 0
mkdir -p ~/docker/xui/db  ~/docker/xui/cert ~/docker/xui/config
chmod 776 -R ~/docker/xui/db  ~/docker/xui/cert ~/docker/xui/config
yum -y install expect
curl -o bbr.sh https://raw.githubusercontent.com/teddysun/across/master/bbr.sh 
chmod 777 *.sh

# create ssl cert
./create_ssl_cert.sh<<EOF
y
$CERT_PATH
$SECOND_DOMAIN
$CF_API_ID
$CF_EMAIL
EOF

# download docker & x-ui-auto
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker
sudo systemctl start docker

# docker build x-ui-auto
cd ..
docker buildx build -t x-ui-auto:v1 -f ./Dockerfile .
docker run -itd --network=host \
-v ~/docker/xui/db/:/etc/x-ui/ \
-v ~/docker/xui/cert/:/root/cert/ \
-v ~/docker/xui/config/:/usr/local/x-ui/bin/ \
--name x-ui-auto --restart=unless-stopped \
x-ui-auto:v1

# enable $WEB_PORT/443 port
#sudo firewall-cmd --zone=public --add-port=$WEB_PORT/tcp --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload
firewall-cmd --list-all

# configure x-ui
cd auto
python3 x-ui-api.py 127.0.0.1 $WEB_PORT admin admin $WEB_URI/ $WS_URI $SUB_DOMAIN

# configure nginx engine
./conf_nginx.sh

# install bbr
./install_bbr.sh