#!/bin/bash
#
# Update All Script
# Updates all system components and tools
#
# Usage: sudo bash scripts/management/update-all.sh
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}

log "Starting update process..."

# System packages
log "Updating system packages..."
apt update
apt upgrade -y
apt autoremove -y
apt autoclean
log_success "System packages updated"

# code-server
log "Updating code-server..."
curl -fsSL https://code-server.dev/install.sh | sh
systemctl restart code-server || log_warning "Failed to restart code-server"
log_success "code-server updated"

# npm global packages
log "Updating npm global packages..."
npm update -g || log_warning "npm global update had issues"
log_success "npm packages updated"

# pip packages
log "Updating Python packages..."
sudo -u "$ACTUAL_USER" pip3 list --outdated --format=json | \
    jq -r '.[] | .name' | \
    xargs -n1 sudo -u "$ACTUAL_USER" pip3 install --user --upgrade || \
    log_warning "Some pip packages failed to update"
log_success "Python packages updated"

# Google Cloud SDK
log "Updating Google Cloud SDK..."
gcloud components update --quiet || log_warning "gcloud update had issues"
log_success "Google Cloud SDK updated"

# Rust
log "Updating Rust..."
sudo -u "$ACTUAL_USER" bash -c 'source ~/.cargo/env && rustup update' || \
    log_warning "Rust update had issues"
log_success "Rust updated"

# Docker images cleanup (optional)
log "Cleaning up Docker..."
docker system prune -f || log_warning "Docker cleanup had issues"
log_success "Docker cleaned up"

log_success "All updates completed!"
log ""
log "Recommended next steps:"
log "  1. Check health: bash scripts/management/health-check.sh"
log "  2. Restart services if needed: sudo systemctl restart code-server"
log "  3. Review logs: journalctl -xe"
