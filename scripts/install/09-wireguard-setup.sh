#!/bin/bash
#
# WireGuard VPN Setup for Virtual Desktop Server
# Creates secure VPN tunnel for accessing the server
#
# Usage: sudo bash scripts/install/09-wireguard-setup.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"; }
log_error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"; }
log_warn() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"; }

# ============================================================
# Configuration
# ============================================================
SERVER_WG_IP="${SERVER_WG_IP:-10.200.200.1}"
SERVER_WG_PORT="${SERVER_WG_PORT:-51820}"
CLIENT_WG_IP="${CLIENT_WG_IP:-10.200.200.2}"
WG_INTERFACE="wg0"
WG_CONFIG_DIR="/etc/wireguard"
CLIENT_CONFIG_DIR="/root/wireguard-clients"

# Get server's public IP
SERVER_PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me)

# ============================================================
# Install WireGuard
# ============================================================
log "Installing WireGuard..."

apt-get update
apt-get install -y wireguard wireguard-tools qrencode

log_success "WireGuard installed"

# ============================================================
# Generate server keys
# ============================================================
log "Generating server keys..."

mkdir -p "${WG_CONFIG_DIR}"
chmod 700 "${WG_CONFIG_DIR}"

# Generate server keys if not exist
if [ ! -f "${WG_CONFIG_DIR}/server_private.key" ]; then
    wg genkey | tee "${WG_CONFIG_DIR}/server_private.key" | wg pubkey > "${WG_CONFIG_DIR}/server_public.key"
    chmod 600 "${WG_CONFIG_DIR}/server_private.key"
fi

SERVER_PRIVATE_KEY=$(cat "${WG_CONFIG_DIR}/server_private.key")
SERVER_PUBLIC_KEY=$(cat "${WG_CONFIG_DIR}/server_public.key")

log_success "Server keys generated"

# ============================================================
# Create server configuration
# ============================================================
log "Creating server configuration..."

cat > "${WG_CONFIG_DIR}/${WG_INTERFACE}.conf" << EOF
# WireGuard Server Configuration
# Virtual Desktop Server VPN
# Generated: $(date)

[Interface]
Address = ${SERVER_WG_IP}/24
ListenPort = ${SERVER_WG_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}

# Enable IP forwarding and NAT
PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Peers will be added below
EOF

chmod 600 "${WG_CONFIG_DIR}/${WG_INTERFACE}.conf"

log_success "Server configuration created"

# ============================================================
# Enable IP forwarding permanently
# ============================================================
log "Enabling IP forwarding..."

if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

log_success "IP forwarding enabled"

# ============================================================
# Create client configuration
# ============================================================
log "Creating first client configuration..."

mkdir -p "${CLIENT_CONFIG_DIR}"
chmod 700 "${CLIENT_CONFIG_DIR}"

# Generate client keys
wg genkey | tee "${CLIENT_CONFIG_DIR}/client1_private.key" | wg pubkey > "${CLIENT_CONFIG_DIR}/client1_public.key"
chmod 600 "${CLIENT_CONFIG_DIR}/client1_private.key"

CLIENT_PRIVATE_KEY=$(cat "${CLIENT_CONFIG_DIR}/client1_private.key")
CLIENT_PUBLIC_KEY=$(cat "${CLIENT_CONFIG_DIR}/client1_public.key")

# Create client configuration
cat > "${CLIENT_CONFIG_DIR}/client1.conf" << EOF
# WireGuard Client Configuration
# Virtual Desktop Server VPN
# Client: client1
# Generated: $(date)

[Interface]
# Client private key
PrivateKey = ${CLIENT_PRIVATE_KEY}
# Client IP in VPN network
Address = ${CLIENT_WG_IP}/32
# DNS servers (optional, use server's DNS or public)
DNS = 1.1.1.1, 8.8.8.8

[Peer]
# Server public key
PublicKey = ${SERVER_PUBLIC_KEY}
# Server address and port
Endpoint = ${SERVER_PUBLIC_IP}:${SERVER_WG_PORT}
# Route all traffic through VPN (use 10.200.200.0/24 for split tunnel)
AllowedIPs = 0.0.0.0/0
# Keep connection alive behind NAT
PersistentKeepalive = 25
EOF

chmod 600 "${CLIENT_CONFIG_DIR}/client1.conf"

# Add client as peer to server config
cat >> "${WG_CONFIG_DIR}/${WG_INTERFACE}.conf" << EOF

# Client: client1
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_WG_IP}/32
EOF

log_success "Client configuration created"

# ============================================================
# Generate QR code for mobile clients
# ============================================================
log "Generating QR code for mobile clients..."

qrencode -t ansiutf8 < "${CLIENT_CONFIG_DIR}/client1.conf"
qrencode -o "${CLIENT_CONFIG_DIR}/client1.png" < "${CLIENT_CONFIG_DIR}/client1.conf"

log_success "QR code generated: ${CLIENT_CONFIG_DIR}/client1.png"

# ============================================================
# Configure firewall
# ============================================================
log "Configuring firewall..."

# UFW
if command -v ufw &> /dev/null; then
    ufw allow ${SERVER_WG_PORT}/udp comment "WireGuard VPN"
    log_success "UFW rule added for WireGuard"
fi

# ============================================================
# Start WireGuard
# ============================================================
log "Starting WireGuard..."

systemctl enable wg-quick@${WG_INTERFACE}
systemctl start wg-quick@${WG_INTERFACE}

log_success "WireGuard started"

# ============================================================
# Create helper scripts
# ============================================================
log "Creating helper scripts..."

# Script to add new clients
cat > /usr/local/bin/wg-add-client << 'SCRIPT'
#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: wg-add-client <client_name>"
    exit 1
fi

CLIENT_NAME="$1"
WG_CONFIG_DIR="/etc/wireguard"
CLIENT_CONFIG_DIR="/root/wireguard-clients"
SERVER_PUBLIC_KEY=$(cat ${WG_CONFIG_DIR}/server_public.key)
SERVER_PUBLIC_IP=$(curl -s https://api.ipify.org)
SERVER_WG_PORT=51820

# Find next available IP
LAST_IP=$(grep "AllowedIPs" ${WG_CONFIG_DIR}/wg0.conf | tail -1 | grep -oP '10\.200\.200\.\K\d+' || echo "1")
NEXT_IP=$((LAST_IP + 1))
CLIENT_IP="10.200.200.${NEXT_IP}"

# Generate keys
mkdir -p "${CLIENT_CONFIG_DIR}"
wg genkey | tee "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}_private.key" | wg pubkey > "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}_public.key"
chmod 600 "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}_private.key"

CLIENT_PRIVATE_KEY=$(cat "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}_private.key")
CLIENT_PUBLIC_KEY=$(cat "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}_public.key")

# Create client config
cat > "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.conf" << EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_PUBLIC_IP}:${SERVER_WG_PORT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

chmod 600 "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.conf"

# Add peer to server
cat >> "${WG_CONFIG_DIR}/wg0.conf" << EOF

# Client: ${CLIENT_NAME}
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}/32
EOF

# Reload WireGuard
wg syncconf wg0 <(wg-quick strip wg0)

# Generate QR code
qrencode -o "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.png" < "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.conf"

echo ""
echo "Client '${CLIENT_NAME}' created!"
echo "IP: ${CLIENT_IP}"
echo "Config: ${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.conf"
echo "QR Code: ${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.png"
echo ""
echo "Scan this QR code with WireGuard mobile app:"
qrencode -t ansiutf8 < "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.conf"
SCRIPT

chmod +x /usr/local/bin/wg-add-client

# Script to list clients
cat > /usr/local/bin/wg-list-clients << 'SCRIPT'
#!/bin/bash
echo "WireGuard Clients:"
echo "=================="
wg show wg0 peers | while read peer; do
    allowed_ips=$(wg show wg0 allowed-ips | grep "$peer" | awk '{print $2}')
    latest_handshake=$(wg show wg0 latest-handshakes | grep "$peer" | awk '{print $2}')
    transfer=$(wg show wg0 transfer | grep "$peer" | awk '{print "rx: "$2", tx: "$3}')
    echo "Peer: ${peer:0:20}..."
    echo "  IP: $allowed_ips"
    echo "  Last handshake: $(date -d @$latest_handshake 2>/dev/null || echo 'never')"
    echo "  Transfer: $transfer"
    echo ""
done
SCRIPT

chmod +x /usr/local/bin/wg-list-clients

log_success "Helper scripts created"

# ============================================================
# Summary
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            🔒 WireGuard VPN Setup Complete                    ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  Server Configuration:                                        ║"
echo "║    Public IP: ${SERVER_PUBLIC_IP}"
echo "║    VPN IP: ${SERVER_WG_IP}"
echo "║    Port: ${SERVER_WG_PORT}/udp"
echo "║    Interface: ${WG_INTERFACE}"
echo "║                                                               ║"
echo "║  Client Configuration:                                        ║"
echo "║    Config file: ${CLIENT_CONFIG_DIR}/client1.conf"
echo "║    QR code: ${CLIENT_CONFIG_DIR}/client1.png"
echo "║    Client IP: ${CLIENT_WG_IP}"
echo "║                                                               ║"
echo "║  Commands:                                                    ║"
echo "║    wg-add-client <name>  - Add new client                    ║"
echo "║    wg-list-clients       - List all clients                  ║"
echo "║    wg show               - Show VPN status                   ║"
echo "║                                                               ║"
echo "║  Download client config and import into WireGuard app        ║"
echo "║                                                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Client QR Code (scan with WireGuard mobile app):"
echo ""
qrencode -t ansiutf8 < "${CLIENT_CONFIG_DIR}/client1.conf"
