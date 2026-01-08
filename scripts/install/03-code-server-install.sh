#!/bin/bash
#
# code-server Installation Script
# Installs and configures code-server with systemd
#
# Usage: sudo bash scripts/install/03-code-server-install.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

log "Installing code-server for user: $ACTUAL_USER"

# Install code-server
log "Downloading and installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh

# Create config directory
log "Creating config directory..."
sudo -u "$ACTUAL_USER" mkdir -p "$ACTUAL_HOME/.config/code-server"

# Generate random password
log "Generating secure password..."
PASSWORD=$(openssl rand -base64 24)

# Create config file
log "Creating config.yaml..."
cat > "$ACTUAL_HOME/.config/code-server/config.yaml" << EOF
bind-addr: 0.0.0.0:8443
auth: password
password: $PASSWORD
cert: true
EOF

# Set ownership and permissions
chown "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.config/code-server/config.yaml"
chmod 600 "$ACTUAL_HOME/.config/code-server/config.yaml"

# Create systemd service
log "Creating systemd service..."
cat > /etc/systemd/system/code-server.service << EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
Environment=PASSWORD=$PASSWORD
ExecStart=/usr/bin/code-server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
log "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start code-server
log "Enabling and starting code-server..."
systemctl enable code-server
systemctl start code-server

# Wait for code-server to start
log "Waiting for code-server to start..."
sleep 5

# Check status
if systemctl is-active --quiet code-server; then
    log_success "code-server is running!"
else
    log_warning "code-server might not have started properly. Check: systemctl status code-server"
fi

# Install recommended extensions
log "Installing recommended VS Code extensions..."
sudo -u "$ACTUAL_USER" code-server --install-extension dbaeumer.vscode-eslint || true
sudo -u "$ACTUAL_USER" code-server --install-extension esbenp.prettier-vscode || true
sudo -u "$ACTUAL_USER" code-server --install-extension eamodio.gitlens || true
sudo -u "$ACTUAL_USER" code-server --install-extension ms-python.python || true
sudo -u "$ACTUAL_USER" code-server --install-extension golang.go || true
sudo -u "$ACTUAL_USER" code-server --install-extension ms-azuretools.vscode-docker || true

log_success "code-server installation completed!"
log ""
log "════════════════════════════════════════════════════════════════"
log "  code-server Access Information"
log "════════════════════════════════════════════════════════════════"
log "  URL: https://34.46.96.77:8443"
log "  Password: $PASSWORD"
log ""
log "  Password is also saved in:"
log "  $ACTUAL_HOME/.config/code-server/config.yaml"
log "════════════════════════════════════════════════════════════════"
log ""
log "To view password later:"
log "  cat ~/.config/code-server/config.yaml | grep password"
log ""
log "To restart code-server:"
log "  sudo systemctl restart code-server"
log ""
log "To view logs:"
log "  journalctl -u code-server -f"
