#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
#Add some basic function here
function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}
function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}
function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}
# check root
[[ $EUID -ne 0 ]] && LOGE "错误:  必须使用root用户运行此脚本!\n" && exit 1
confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [默认$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}
echo -E ""
LOGD "******使用说明******"
LOGI "该脚本将使用Acme脚本申请证书,使用时需保证:"
LOGI "1.知晓Cloudflare 注册邮箱"
LOGI "2.知晓Cloudflare Global API Key"
LOGI "3.域名已通过Cloudflare进行解析到当前服务器"
LOGI "4.该脚本申请证书默认安装路径为{CertPath}目录"
confirm "我已确认以上内容[y/n]" "y"
if [ $? -eq 0 ]; then
	cd ~
	LOGI "安装Acme脚本"
	curl https://get.acme.sh | sh
	if [ $? -ne 0 ]; then
		LOGE "安装acme脚本失败"
		exit 1
	fi
	CertPath="/root/cert"
	CF_Domain=""
	CF_GlobalKey=""
	CF_AccountEmail=""
	
	LOGD "请设置证书存放路径:"
	read -p "Input your cert output path here:" SaveCertPath
	LOGD "你的证书存放路径设置为:${SaveCertPath}"

	if [ ! -d "$CertPath" ]; then
		mkdir $CertPath
	else
		rm -rf $CertPath
		mkdir $CertPath
	fi
	LOGD "请设置域名:"
	read -p "Input your domain here:" CF_Domain
	LOGD "你的域名设置为:${CF_Domain}"
	LOGD "请设置API密钥:"
	read -p "Input your key here:" CF_GlobalKey
	LOGD "你的API密钥为:${CF_GlobalKey}"
	LOGD "请设置注册邮箱:"
	read -p "Input your email here:" CF_AccountEmail
	LOGD "你的注册邮箱为:${CF_AccountEmail}"
	~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
	if [ $? -ne 0 ]; then
		LOGE "修改默认CA为Lets'Encrypt失败,脚本退出"
		exit 1
	fi
	export CF_Key="${CF_GlobalKey}"
	export CF_Email=${CF_AccountEmail}
	~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain} --log
	if [ $? -ne 0 ]; then
		LOGE "证书签发失败,脚本退出"
		exit 1
	else
		LOGI "证书签发成功,安装中..."
	fi
	~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file ${CertPath}ca.cer \
	--cert-file ${CertPath}${CF_Domain}.cer --key-file ${CertPath}${CF_Domain}.key \
	--fullchain-file ${CertPath}"fullchain.cer"
	if [ $? -ne 0 ]; then
		LOGE "证书安装失败,脚本退出"
		exit 1
	else
		LOGI "证书安装成功,开启自动更新..."
		cp -rf /root/.acme.sh/${CF_Domain}_ecc/* $SaveCertPath
	fi
	~/.acme.sh/acme.sh --upgrade --auto-upgrade
	if [ $? -ne 0 ]; then
		LOGE "自动更新设置失败,脚本退出"
		ls -lah $CertPath
		chmod 755 $CertPath
		exit 1
	else
		LOGI "证书已安装且已开启自动更新,具体信息如下"
		ls -lah $CertPath
		chmod 755 $CertPath
	fi
fi