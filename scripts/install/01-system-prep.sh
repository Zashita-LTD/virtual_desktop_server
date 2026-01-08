#!/bin/bash
#
# System Preparation Script
# Updates system packages and installs base dependencies
#
# Usage: sudo bash scripts/install/01-system-prep.sh
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

log "Starting system preparation..."

# Update package lists
log "Updating package lists..."
apt update

# Upgrade existing packages
log "Upgrading existing packages (this may take several minutes)..."
DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Install base dependencies
log "Installing base dependencies..."
apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    jq \
    tree \
    ncdu \
    net-tools \
    dnsutils \
    htop \
    vim \
    nano

# Install unattended-upgrades for automatic security updates
log "Setting up automatic security updates..."
apt install -y unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/20auto-upgrades

# Configure timezone (set to UTC by default)
log "Configuring timezone..."
timedatectl set-timezone UTC

# Enable NTP time synchronization
log "Enabling NTP time synchronization..."
timedatectl set-ntp true

# Clean up
log "Cleaning up..."
apt autoremove -y
apt autoclean

log_success "System preparation completed!"
