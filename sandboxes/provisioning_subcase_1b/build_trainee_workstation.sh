#!/bin/bash
set -e

# Example provisioning steps for the trainee workstation VM

###############################################################################
# Offline installation paths
###############################################################################
# The image this script runs on is expected to ship with all required tooling
# already downloaded to a local directory.  By default we look for the
# artefacts next to this script under "offline_artifacts" but the location can
# be overridden via the ARTIFACTS_DIR environment variable.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-${SCRIPT_DIR}/offline_artifacts}"
APT_REPO="${ARTIFACTS_DIR}/apt"
PIP_REPO="${ARTIFACTS_DIR}/pip"
CALDERA_ARCHIVE="${ARTIFACTS_DIR}/caldera.tar.gz"
ZAP_SNAP="${ARTIFACTS_DIR}/zaproxy.snap"

# Sanity check that artefacts are present
for path in "$APT_REPO" "$PIP_REPO" "$CALDERA_ARCHIVE" "$ZAP_SNAP"; do
    if [ ! -e "$path" ]; then
        echo "Required artefact $path not found" >&2
        exit 1
    fi
done

###############################################################################
# Approved tooling list
###############################################################################
ALLOWED_TOOLS=(nmap zaproxy gvm caldera)
TOOLS_TO_INSTALL=(nmap zaproxy gvm caldera)

for tool in "${TOOLS_TO_INSTALL[@]}"; do
    if [[ ! " ${ALLOWED_TOOLS[*]} " =~ ${tool} ]]; then
        echo "Tool ${tool} is not in the allowed list" >&2
        exit 1
    fi
done

###############################################################################
# Configure local APT repository and install base packages
###############################################################################
echo "deb [trusted=yes] file:${APT_REPO} ./" >/etc/apt/sources.list.d/offline.list
apt-get update
apt-get install -y --no-install-recommends nmap gvm python3-pip git curl snapd

###############################################################################
# Install OWASP ZAP from local snap file
###############################################################################
if ! command -v snap >/dev/null 2>&1; then
    echo "snapd failed to install" >&2
    exit 1
fi
systemctl enable --now snapd.socket
ln -sf /var/lib/snapd/snap /snap
snap install --dangerous "${ZAP_SNAP}" --classic

###############################################################################
# Configure and verify OpenVAS (Greenbone)
###############################################################################
gvm-setup
gvm-start
for _ in {1..30}; do
    if curl -k -sSf https://127.0.0.1:9392 >/dev/null 2>&1; then
        break
    fi
    sleep 1
done
curl -k -sSf https://127.0.0.1:9392 >/dev/null 2>&1
gvm-stop

###############################################################################
# Launch ZAP in daemon mode to verify availability
###############################################################################
zaproxy -daemon -port 8090 -host 127.0.0.1 &
ZAP_PID=$!
for _ in {1..30}; do
    if curl -sSf http://127.0.0.1:8090/ >/dev/null 2>&1; then
        break
    fi
    sleep 1
done
curl -sSf http://127.0.0.1:8090/ >/dev/null 2>&1
zaproxy -cmd -shutdown >/dev/null 2>&1 || kill "$ZAP_PID" || true

###############################################################################
# Install MITRE Caldera from local artefacts
###############################################################################
if [ ! -d /opt/caldera ]; then
    mkdir -p /opt
    tar -xf "${CALDERA_ARCHIVE}" -C /opt
    pip3 install --no-index --find-links "${PIP_REPO}" -r /opt/caldera/requirements.txt
fi

###############################################################################
# Verify each tool runs without missing dependencies
###############################################################################
nmap --version >/dev/null
zaproxy --version >/dev/null 2>&1 || zaproxy -version >/dev/null 2>&1
gvm-manage-certs --version >/dev/null 2>&1 || gvmd --version >/dev/null 2>&1
python3 /opt/caldera/server.py --help >/dev/null 2>&1
