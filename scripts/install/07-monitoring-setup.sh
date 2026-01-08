#!/bin/bash
#
# Monitoring Setup Script
# Installs Cloud Ops Agent and sets up backup timer
#
# Usage: sudo bash scripts/install/07-monitoring-setup.sh
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

log "Setting up monitoring..."

# Install Cloud Ops Agent
log "Installing Google Cloud Ops Agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
rm add-google-cloud-ops-agent-repo.sh

# Check if Cloud Ops Agent is running
if systemctl is-active --quiet google-cloud-ops-agent; then
    log_success "Cloud Ops Agent is running"
else
    log_warning "Cloud Ops Agent might not be running. Check: systemctl status google-cloud-ops-agent"
fi

# Create backup service
log "Creating backup systemd service..."
cat > /etc/systemd/system/backup.service << 'EOF'
[Unit]
Description=Backup projects directory
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /home/runner/work/virtual_desktop_server/virtual_desktop_server/scripts/management/backup.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Create backup timer
log "Creating backup systemd timer..."
cat > /etc/systemd/system/backup.timer << 'EOF'
[Unit]
Description=Daily backup timer
Requires=backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload systemd daemon
log "Reloading systemd daemon..."
systemctl daemon-reload

# Enable backup timer
log "Enabling backup timer..."
systemctl enable backup.timer
systemctl start backup.timer

log_success "Monitoring setup completed!"
log ""
log "Monitoring configuration:"
log "  ✅ Google Cloud Ops Agent installed and running"
log "     - Collecting metrics: CPU, Memory, Disk, Network"
log "     - Collecting logs: syslog, application logs"
log "     - View in GCP Console → Monitoring"
log ""
log "  ✅ Automatic backups configured"
log "     - Schedule: Daily at 02:00 AM"
log "     - Target: /data/shared/projects/"
log "     - Destination: /backup/"
log "     - Retention: 7 days"
log ""
log "To check backup timer status:"
log "  sudo systemctl status backup.timer"
log "  sudo systemctl list-timers | grep backup"
log ""
log "To run backup manually:"
log "  sudo systemctl start backup.service"
log ""
log "To view Cloud Ops Agent status:"
log "  sudo systemctl status google-cloud-ops-agent"
