#!/bin/bash
set -euo pipefail

# Logging
exec > >(tee -a /var/log/startup-script.log)
exec 2>&1

echo "[$(date)] ========================================="
echo "[$(date)] Starting Virtual Desktop Server Setup"
echo "[$(date)] ========================================="

# Variables from Terraform
USERNAME="${username}"
ALERT_EMAIL="${alert_email}"
PROJECT_ID="${project_id}"
REGION="${region}"

# Update system
echo "[$(date)] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Install Git
echo "[$(date)] Installing Git..."
apt-get install -y git curl wget

# Clone repository
echo "[$(date)] Cloning repository..."
REPO_DIR="/opt/virtual_desktop_server"
if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/Zashita-LTD/virtual_desktop_server.git "$REPO_DIR"
fi

cd "$REPO_DIR"

# Create .env file
echo "[$(date)] Creating .env file..."
cat > "$REPO_DIR/.env" <<EOF
SERVER_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
DOMAIN=
CODE_SERVER_PASSWORD=
GCP_PROJECT_ID=$PROJECT_ID
GCP_REGION=$REGION
GCP_ZONE=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | cut -d'/' -f4)
BACKUP_DIR=/backup
BACKUP_RETENTION_DAYS=7
ALERT_EMAIL=$ALERT_EMAIL
EOF

# Make scripts executable
echo "[$(date)] Making scripts executable..."
chmod +x scripts/install/*.sh
chmod +x scripts/management/*.sh
chmod +x scripts/workspaces/*.sh

# Mount persistent disk if exists
if [ -e /dev/disk/by-id/google-data-disk ]; then
  echo "[$(date)] Mounting persistent disk..."
  mkdir -p /data
  
  # Check if disk is formatted
  if ! blkid /dev/disk/by-id/google-data-disk; then
    echo "[$(date)] Formatting persistent disk..."
    mkfs.ext4 -F /dev/disk/by-id/google-data-disk
  fi
  
  # Add to fstab
  if ! grep -q "/dev/disk/by-id/google-data-disk" /etc/fstab; then
    echo "/dev/disk/by-id/google-data-disk /data ext4 defaults,nofail 0 2" >> /etc/fstab
  fi
  
  mount -a
fi

# Run installation scripts
echo "[$(date)] Running installation scripts..."
./scripts/install/00-master-install.sh

# Setup for specific user
echo "[$(date)] Setting up for user $USERNAME..."
if id "$USERNAME" &>/dev/null; then
  # Copy workspace configs to user home
  mkdir -p /home/$USERNAME/.config
  cp -r "$REPO_DIR/config/workspaces" /home/$USERNAME/.config/
  chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
fi

echo "[$(date)] ========================================="
echo "[$(date)] Virtual Desktop Server Setup Complete!"
echo "[$(date)] ========================================="
echo "[$(date)] Access code-server at: https://$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google"):8443"
echo "[$(date)] Get password with: cat /home/$USERNAME/.config/code-server/config.yaml"
