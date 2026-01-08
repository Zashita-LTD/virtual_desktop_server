#!/bin/bash
#
# Development Tools Installation Script
# Installs Git, Docker, Node.js, Python, Go, Rust, and utilities
#
# Usage: sudo bash scripts/install/04-dev-tools.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}

log "Installing development tools..."

# Git (already installed in system-prep, but ensure latest)
log "Installing Git..."
add-apt-repository ppa:git-core/ppa -y || true
apt update
apt install -y git

# GitHub CLI
log "Installing GitHub CLI (gh)..."
type -p curl >/dev/null || apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt install -y gh

# Docker
log "Installing Docker..."
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
usermod -aG docker "$ACTUAL_USER"

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Node.js v20 LTS
log "Installing Node.js v20 LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install yarn and pnpm
log "Installing yarn and pnpm..."
npm install -g yarn pnpm

# Python 3.12+ (Ubuntu 24.04 comes with Python 3.12)
log "Installing Python and tools..."
apt install -y python3 python3-pip python3-venv python3-dev

# Install poetry
log "Installing Poetry..."
curl -sSL https://install.python-poetry.org | sudo -u "$ACTUAL_USER" python3 -

# Go 1.21+
log "Installing Go..."
GO_VERSION="1.21.6"
wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Add Go to PATH for all users
echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh

# Rust
log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -u "$ACTUAL_USER" sh -s -- -y

# Build tools
log "Installing build tools..."
apt install -y build-essential gcc g++ make cmake

# tmux and screen
log "Installing tmux and screen..."
apt install -y tmux screen

# btop (modern resource monitor)
log "Installing btop..."
apt install -y btop || {
    log "btop not available in repos, skipping..."
}

# Utilities
log "Installing utilities..."
apt install -y jq tree ncdu speedtest-cli

log_success "Development tools installation completed!"
log ""
log "Installed tools:"
log "  - Git $(git --version | head -n1)"
log "  - GitHub CLI $(gh --version | head -n1)"
log "  - Docker $(docker --version)"
log "  - Node.js $(node --version)"
log "  - npm $(npm --version)"
log "  - yarn $(yarn --version)"
log "  - pnpm $(pnpm --version)"
log "  - Python $(python3 --version)"
log "  - pip $(pip3 --version)"
log "  - Go $(/usr/local/go/bin/go version)"
log "  - Rust ($(sudo -u "$ACTUAL_USER" bash -c 'source ~/.cargo/env && rustc --version'))"
log "  - tmux, screen, htop, btop, jq, tree, ncdu"
log ""
log "Note: You may need to log out and back in for group changes to take effect."
