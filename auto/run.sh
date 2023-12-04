#!/bin/bash
source ./config.sh

# close SELINUX
setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# environment configuration
yum -y install expect
yum -y install net-tools
yum -y install python3-devel libjpeg-devel zlib-devel gcc
pip3 install qrcode
pip3 install Pillow
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker
sudo systemctl start docker
mkdir -p ~/docker/xui/db  ~/docker/xui/cert ~/docker/xui/config
chmod 776 -R ~/docker/xui/db  ~/docker/xui/cert ~/docker/xui/config
curl -o bbr.sh https://raw.githubusercontent.com/teddysun/across/master/bbr.sh 
chmod 777 *.sh

# create ssl cert
./create_ssl_cert.sh<<EOF
y
$CERT_PATH
$DOMAIN
$CF_API_ID
$CF_EMAIL
EOF

# docker build x-ui-auto
cd ..
docker buildx build -t x-ui-auto:v1 -f ./Dockerfile .
docker run -itd --network=host \
-v ~/docker/xui/db/:/etc/x-ui/ \
-v ~/docker/xui/cert/:/root/cert/ \
-v ~/docker/xui/config/:/usr/local/x-ui/bin/ \
--name x-ui-auto --restart=unless-stopped \
x-ui-auto:v1

# firewall setting
#sudo firewall-cmd --zone=public --add-port=$WEB_PORT/tcp --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload
firewall-cmd --list-all

# configure nginx engine
cd auto
./conf_nginx.sh

# record dns in cloudflare
./cloudflare_dns_record.sh

# install bbr
./install_bbr.sh

# configure x-ui
python3 x-ui-api.py $WEB_IP $WEB_PORT admin admin $WS_PORT $WEB_URI/ $WS_URI $DOMAIN

# send email
python3 smtp.py $SMTP_SERVER \
                $SMTP_PORT \
                $SMTP_USERNAME \
                $SMTP_PASSWORD \
                $SENDER_EMAIL \
                $RECEIVER_EMAIL \
                "Your vmess server configuration is done!" \
                "$(cat ./vmess_address.txt)" \
                "./vmess_qrcode.jpg"
 
# reboot to activate bbr
echo "Congratulations! Everything is settled down!"
echo "Now reboot machine to activate bbr"
reboot