# MTProto Proxy Auto-Installer

This script automates the installation and setup of the [MTProto Proxy](https://github.com/alexbers/mtprotoproxy) on your Linux server, including:

- Cloning the official MTProto Proxy repository
- Installing required Python dependencies
- Creating a customizable configuration file
- Setting up a systemd service to run the proxy automatically on boot
- Opening the proxy port in your firewall (supports `ufw`, `firewalld`, and basic `iptables`)


---

## Usage

1. **Download the installer script**

```bash
wget https://github.com/thanhtungtav4/mtprotoproxy-script-auto/blob/main/auto_install_mtprotoproxy.sh
chmod +x auto_install_mtprotoproxy.sh

## Usage

2. **Run the installer with root privileges**

sudo ./auto_install_mtprotoproxy.sh
