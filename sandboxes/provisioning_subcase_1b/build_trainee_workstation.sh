#!/bin/bash
set -e

# Example provisioning steps for the trainee workstation VM

apt-get update

# List of approved pentesting tools
ALLOWED_TOOLS=(nmap zaproxy gvm caldera)

# Tools requested for installation
TOOLS_TO_INSTALL=(nmap zaproxy gvm caldera)

# Ensure all requested tools are allowed
for tool in "${TOOLS_TO_INSTALL[@]}"; do
    if [[ ! " ${ALLOWED_TOOLS[*]} " =~ " ${tool} " ]]; then
        echo "Tool ${tool} is not in the allowed list" >&2
        exit 1
    fi
done

# Base packages
apt-get install -y nmap gvm python3-pip git

# Install OWASP ZAP via snap
if ! command -v snap >/dev/null 2>&1; then
    apt-get install -y snapd
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
fi
snap install zaproxy --classic

# Install MITRE Caldera
if [ ! -d /opt/caldera ]; then
    git clone https://github.com/mitre/caldera /opt/caldera
    pip3 install -r /opt/caldera/requirements.txt
fi

# Verify each tool runs without missing dependencies
nmap --version >/dev/null
zaproxy --version >/dev/null 2>&1 || zaproxy -version >/dev/null 2>&1
gvm-manage-certs --version >/dev/null 2>&1 || gvmd --version >/dev/null 2>&1
python3 /opt/caldera/server.py --help >/dev/null 2>&1
