# MTProto Proxy Auto-Installer

This script automates installing and configuring the [MTProto Proxy](https://github.com/alexbers/mtprotoproxy) on your Linux server. It performs:

- Cloning the official MTProto Proxy repository  
- Installing Python dependencies  
- Creating a customizable `config.py` file  
- Setting up a systemd service for auto-start on boot  
- Opening the proxy port in your firewall (supports `ufw`, `firewalld`, and `iptables`)  

---

## Usage

1. **Download the installer script:**

   ```bash
   wget https://github.com/thanhtungtav4/mtprotoproxy-script-auto/blob/main/auto_install_mtprotoproxy.sh
   chmod +x auto_install_mtprotoproxy.sh
