import sys
import requests
from urllib.parse import urlencode, quote
import uuid
import json
import base64
import qrcode

g_id = str(uuid.uuid4())
g_vmess_addr_filename = "vmess_address.txt"
g_vmess_qrcode_filename = "vmess_qrcode.jpg"

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

def update_xray(session, ip, port, proxyPort, wsPath, host):
    global g_id
    url = f"http://{ip}:{port}/xui/inbound/add"
    data1 = {
        "up": 0,
        "down": 0,
        "total": 0,
        "remark": "vmess",
        "enable": True,
        "expiryTime": 0,
        "listen": "",
        "port": proxyPort,
        "protocol": "vmess"
    }
    data2 = {
        "settings": {
            "clients": [{"id": g_id, "alterId": 0}],
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
    config_json = json.dumps(vmess_config)
    base64_config = base64.urlsafe_b64encode(config_json.encode()).decode()
    vmess_link = f"vmess://{base64_config}"
    with open(file_path, 'w') as file:
        file.write(vmess_link)
    print("Vmess addr:", vmess_link)
    print("Vmess QRcode:")
    # print qrcode to terminal
    qr = qrcode.QRCode()
    qr.border = 1
    qr.add_data(vmess_link)
    qr.make()
    qr.print_ascii(out=None, tty=False, invert=True)
    # save qrcode to jpg
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(g_vmess_qrcode_filename)

if __name__ == "__main__":
    if len(sys.argv) != 9:
        print("Usage: python3 script.py ip port username password proxyPort webBasePath wsPath host")
        sys.exit(1)

    ip, port, username, password, proxyPort, webBasePath, wsPath, host = sys.argv[1:]

    with requests.Session() as session:
        try:
            port = int(port)
        except ValueError:
            print("Error: Port must be an integer.")
            sys.exit(1)

        print(f"Starting with IP: {ip}, Port: {port}, Username: {username}, Password: {password}, proxyPort: {proxyPort}, Web Base Path: {webBasePath}, WS Path: {wsPath}, Host: {host}")
        local_ip = "127.0.0.1"
        login(session, local_ip, port, username, password)
        config = get_current_config(session, local_ip, port)
        update_setting(session, local_ip, port, webBasePath, config["obj"])
        update_xray(session, local_ip, port, proxyPort, wsPath, host)

        # 保存VMess链接到文件
        save_vmess({
            "v": "2",
            "ps": "vmess",
            "add": host,
            "port": 443,
            "id": g_id,
            "aid": 0,
            "net": "ws",
            "type": "none",
            "host": host,
            "path": wsPath,
            "tls": "tls"
        }, g_vmess_addr_filename)