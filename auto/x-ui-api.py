import sys
import requests
from urllib.parse import urlencode, quote
import uuid
import json
import base64

uuid = ""

def login(session, ip, port, username, password):
    url = f"http://{ip}:{port}/login"
    data = {"username": username, "password": password}
    response = session.post(url, json=data)
    response.raise_for_status()
    print(f"Login Status Code: {response.status_code}")
    print(f"Login Response: {response.text}")

def get_current_config(session, ip, port):
    url = f"http://{ip}:{port}/xui/setting/all"
    response = session.post(url)
    response.raise_for_status()
    print(f"Get Config Status Code: {response.status_code}")
    print(f"Get Config Response: {response.text}")
    return response.json()

def update_setting(session, ip, port, webBasePath, current_config):
    url = f"http://{ip}:{port}/xui/setting/update"
    data1 = {
        "webListen": current_config.get("webListen", ""),
        "webPort": port,
        "webCertFile": current_config.get("webCertFile", ""),
        "webKeyFile": current_config.get("webKeyFile", ""),
        "webBasePath": webBasePath
    }
    data = urlencode(data1)+"&xrayTemplateConfig="+quote(json.dumps(json.loads(current_config.get("xrayTemplateConfig", {}))))+"&timeLocation="+current_config.get("timeLocation", {})
    print(data)
    response = session.post(url, data=data, headers={"Content-Type": "application/x-www-form-urlencoded"})
    response.raise_for_status()
    print(f"Update Setting Status Code: {response.status_code}")
    print(f"Update Setting Response: {response.text}")

def update_xray(session, ip, port, wsPath, host):
    global uuid
    url = f"http://{ip}:{port}/xui/inbound/add"
    uuid = str(uuid.uuid4())
    data1 = {
        "up": 0,
        "down": 0,
        "total": 0,
        "remark": "vmess",
        "enable": True,
        "expiryTime": 0,
        "listen": "",
        "port": 45625,
        "protocol": "vmess"
    }
    data2 = {
        "settings": {
            "clients": [{"id": uuid, "alterId": 0}],
            "disableInsecureEncryption": False
        },
        "streamSettings": {
            "network": "ws",
            "security": "none",
            "wsSettings": {"path": wsPath, "headers": {"Host": host}}
        },
        "sniffing": {"enabled": True, "destOverride": ["http", "tls"]}
    }
    data=urlencode(data1)+"&settings="+quote(json.dumps(data2["settings"]))+"&streamSettings="+quote(json.dumps(data2["streamSettings"]))+"&sniffing="+quote(json.dumps(data2["sniffing"]))
    print(data)
    response = session.post(url, data=data, headers={"Content-Type": "application/x-www-form-urlencoded"})
    response.raise_for_status()
    print(f"Update Xray Status Code: {response.status_code}")
    print(f"Update Xray Response: {response.text}")

    def save_vmess(vmess_config, file_path):
        # 将配置信息转换为JSON字符串
        config_json = json.dumps(vmess_config)

        # 对JSON字符串进行Base64编码
        base64_config = base64.urlsafe_b64encode(config_json.encode()).decode()

        # 拼接VMess链接
        vmess_link = f"vmess://{base64_config}"

        # 保存VMess链接到文件
        with open(file_path, 'w') as file:
            file.write(vmess_link)

        print(f"VMess链接已保存到文件: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) != 8:
        print("Usage: python3 script.py ip port username password webBasePath wsPath host")
        sys.exit(1)

    ip, port, username, password, webBasePath, wsPath, host = sys.argv[1:]

    with requests.Session() as session:
        try:
            port = int(port)
        except ValueError:
            print("Error: Port must be an integer.")
            sys.exit(1)

        print(f"Starting with IP: {ip}, Port: {port}, Username: {username}, Password: {password}, Web Base Path: {webBasePath}, WS Path: {wsPath}, Host: {host}")
        local_ip = "127.0.0.1"
        login(session, local_ip, port, username, password)
        config = get_current_config(session, local_ip, port)
        update_setting(session, local_ip, port, webBasePath, config["obj"])
        update_xray(session, local_ip, port, wsPath, host)

        # 保存VMess链接到文件
        save_vmess({
            "v": "2",
            "ps": "vmess",
            "add": ip,
            "port": port,
            "id": uuid,
            "aid": 0,
            "net": "ws",
            "type": "none",
            "host": host,
            "path": wsPath,
            "tls": "none"
        }, 'vmess_address.txt')