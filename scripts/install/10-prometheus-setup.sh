#!/bin/bash
#
# Prometheus Monitoring Stack Installation
# Installs Prometheus, Grafana, Alertmanager, and Node Exporter
#
# Usage: sudo bash scripts/install/08-prometheus-setup.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"; }
log_error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"; }

# ============================================================
# Configuration
# ============================================================
PROMETHEUS_VERSION="2.50.1"
NODE_EXPORTER_VERSION="1.7.0"
ALERTMANAGER_VERSION="0.27.0"
GRAFANA_VERSION="10.4.1"

# ============================================================
# Install Node Exporter
# ============================================================
log "Installing Node Exporter v${NODE_EXPORTER_VERSION}..."

cd /tmp
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar -xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
rm -rf node_exporter-*

# Create node_exporter user
useradd -rs /bin/false node_exporter 2>/dev/null || true

# Create systemd service
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now node_exporter
log_success "Node Exporter installed and running on 127.0.0.1:9100"

# ============================================================
# Install Prometheus
# ============================================================
log "Installing Prometheus v${PROMETHEUS_VERSION}..."

cd /tmp
wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
tar -xzf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus" /usr/local/bin/
mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool" /usr/local/bin/
rm -rf prometheus-*

# Create prometheus user and directories
useradd -rs /bin/false prometheus 2>/dev/null || true
mkdir -p /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Copy configuration
if [ -f "/opt/virtual_desktop_server/config/monitoring/prometheus.yml" ]; then
    cp /opt/virtual_desktop_server/config/monitoring/prometheus.yml /etc/prometheus/
    cp /opt/virtual_desktop_server/config/monitoring/alerts.yml /etc/prometheus/
fi

chown -R prometheus:prometheus /etc/prometheus

# Create systemd service
cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.listen-address=127.0.0.1:9090 \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --storage.tsdb.retention.time=30d

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus
log_success "Prometheus installed and running on 127.0.0.1:9090"

# ============================================================
# Install Alertmanager
# ============================================================
log "Installing Alertmanager v${ALERTMANAGER_VERSION}..."

cd /tmp
wget -q "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
tar -xzf "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
mv "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager" /usr/local/bin/
mv "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/amtool" /usr/local/bin/
rm -rf alertmanager-*

# Create alertmanager user and directories
useradd -rs /bin/false alertmanager 2>/dev/null || true
mkdir -p /etc/alertmanager /var/lib/alertmanager
chown alertmanager:alertmanager /var/lib/alertmanager

# Copy configuration
if [ -f "/opt/virtual_desktop_server/config/monitoring/alertmanager.yml" ]; then
    cp /opt/virtual_desktop_server/config/monitoring/alertmanager.yml /etc/alertmanager/
fi

chown -R alertmanager:alertmanager /etc/alertmanager

# Create systemd service
cat > /etc/systemd/system/alertmanager.service << 'EOF'
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --storage.path=/var/lib/alertmanager/ \
    --web.listen-address=127.0.0.1:9093

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now alertmanager
log_success "Alertmanager installed and running on 127.0.0.1:9093"

# ============================================================
# Install Grafana
# ============================================================
log "Installing Grafana..."

apt-get install -y apt-transport-https software-properties-common

wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install -y grafana

# Configure Grafana to listen on localhost only
sed -i 's/;http_addr =/http_addr = 127.0.0.1/' /etc/grafana/grafana.ini

# Copy provisioning configs
if [ -d "/opt/virtual_desktop_server/config/monitoring" ]; then
    cp /opt/virtual_desktop_server/config/monitoring/grafana-datasources.yml /etc/grafana/provisioning/datasources/datasources.yml
    cp /opt/virtual_desktop_server/config/monitoring/grafana-dashboards.yml /etc/grafana/provisioning/dashboards/dashboards.yml
fi

systemctl daemon-reload
systemctl enable --now grafana-server
log_success "Grafana installed and running on 127.0.0.1:3000"

# ============================================================
# Create Nginx config for monitoring
# ============================================================
log "Creating Nginx configuration for monitoring access..."

cat > /etc/nginx/sites-available/monitoring << 'EOF'
# Monitoring endpoints (requires authentication)
# Access via VPN or OAuth2 proxy

server {
    listen 127.0.0.1:9091;
    server_name localhost;

    # Prometheus
    location /prometheus/ {
        proxy_pass http://127.0.0.1:9090/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Grafana
    location /grafana/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        rewrite ^/grafana/(.*) /$1 break;
    }

    # Alertmanager
    location /alertmanager/ {
        proxy_pass http://127.0.0.1:9093/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

log_success "Nginx monitoring config created"

# ============================================================
# Summary
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         📊 Prometheus Stack Installation Complete             ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  Services (localhost only):                                   ║"
echo "║    Prometheus:     http://127.0.0.1:9090                     ║"
echo "║    Alertmanager:   http://127.0.0.1:9093                     ║"
echo "║    Grafana:        http://127.0.0.1:3000                     ║"
echo "║    Node Exporter:  http://127.0.0.1:9100                     ║"
echo "║                                                               ║"
echo "║  Default Grafana credentials:                                 ║"
echo "║    Username: admin                                            ║"
echo "║    Password: admin (change on first login!)                  ║"
echo "║                                                               ║"
echo "║  Access monitoring via:                                       ║"
echo "║    - SSH tunnel: ssh -L 3000:localhost:3000 user@server      ║"
echo "║    - VPN: Connect via WireGuard                              ║"
echo "║                                                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
