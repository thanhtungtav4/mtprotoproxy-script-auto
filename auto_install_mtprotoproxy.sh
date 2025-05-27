#!/bin/bash

# Define variables
INSTALL_DIR="/root/mtprotoproxy"
SERVICE_FILE="/etc/systemd/system/mtprotoproxy.service"
REPO_URL="https://github.com/alexbers/mtprotoproxy.git"
PYTHON_BIN=$(command -v python3)

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
elif command -v yum >/dev/null 2>&1; then
    PACKAGE_MANAGER="yum"
elif command -v dnf >/dev/null 2>&1; then
    PACKAGE_MANAGER="dnf"
else
    echo "No supported package manager found (apt, yum, or dnf). Exiting."
    exit 1
fi

# Prompt user for port and secret key
read -rp "Enter the port for MTProto Proxy (default 80): " PORT
PORT=${PORT:-80}

read -rp "Enter the secret key (32 hex chars, default 00000000000000000000000000000001): " SECRET
SECRET=${SECRET:-00000000000000000000000000000001}

# Update and install required packages
echo "Updating system and installing dependencies..."
if [ "$PACKAGE_MANAGER" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y
    sudo apt install python3 python3-pip git -y
else
    sudo "$PACKAGE_MANAGER" -y update
    sudo "$PACKAGE_MANAGER" -y install python3 python3-pip git
fi

# Verify Python installation
if [ -z "$PYTHON_BIN" ]; then
    echo "Python3 is not installed. Installing..."
    if [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt install python3 -y
    else
        sudo "$PACKAGE_MANAGER" -y install python3
    fi
    PYTHON_BIN=$(command -v python3)
    if [ -z "$PYTHON_BIN" ]; then
        echo "Failed to install Python3. Exiting."
        exit 1
    fi
fi

# Clone the repository
echo "Cloning MTProto Proxy repository..."
if [[ -d "$INSTALL_DIR" ]]; then
    echo "Directory $INSTALL_DIR already exists. Skipping clone."
else
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Navigate to installation directory
cd "$INSTALL_DIR" || exit

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install -r requirements.txt

# Create configuration file
echo "Setting up configuration file..."
cat > config.py <<EOL
PORT = $PORT
BIND_IP = "0.0.0.0"

USERS = {
    "default": "$SECRET",  # User secret
}

MODES = {
    "classic": False,
    "secure": False,
    "tls": True
}

TLS_DOMAIN = "www.google.com"  # Replace with a valid domain
AD_TAG = ""  # Optional: Add your advertising tag here
EOL

# Open the port in firewall (try ufw, fallback to iptables)
echo "Opening port $PORT in firewall..."
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow "$PORT"/tcp
    sudo ufw reload
elif command -v firewall-cmd >/dev/null 2>&1; then
    sudo firewall-cmd --add-port=${PORT}/tcp --permanent
    sudo firewall-cmd --reload
else
    # fallback to iptables (only for IPv4)
    sudo iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
    echo "Remember to save iptables rules if needed!"
fi

# Create systemd service file
echo "Creating systemd service file..."
cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=MTProto Proxy
After=network.target

[Service]
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$PYTHON_BIN $INSTALL_DIR/mtprotoproxy.py
Restart=always
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
echo "Reloading systemd and starting MTProto Proxy service..."
sudo systemctl daemon-reload
sudo systemctl enable mtprotoproxy
sudo systemctl start mtprotoproxy

# Display service status
echo "MTProto Proxy service status:"
sudo systemctl status mtprotoproxy --no-pager

echo "Installation complete! MTProto Proxy is running on port $PORT with secret $SECRET."
