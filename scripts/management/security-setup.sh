#!/bin/bash
#
# Security Setup Script
# Generates strong passwords and creates secure configuration files
#
# Usage: bash scripts/management/security-setup.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d '=' | head -c 32
}

print_header "🔐 Security Setup for Virtual Desktop Server"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. Some files will be created for root user."
fi

# ============================================================
# 1. Generate Docker .env file
# ============================================================
print_header "1. Docker Environment Setup"

DOCKER_ENV_FILE="${REPO_DIR:-/opt/virtual_desktop_server}/docker/.env"

if [ -f "$DOCKER_ENV_FILE" ]; then
    print_warning "Docker .env already exists. Backing up..."
    cp "$DOCKER_ENV_FILE" "${DOCKER_ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi

cat > "$DOCKER_ENV_FILE" << EOF
# Docker Compose Environment Variables
# Generated: $(date)
# SECURITY: Do not commit this file to version control!

# PostgreSQL
POSTGRES_USER=developer
POSTGRES_PASSWORD=$(generate_password)
POSTGRES_DB=devdb

# Redis
REDIS_PASSWORD=$(generate_password)

# MongoDB
MONGO_USER=developer
MONGO_PASSWORD=$(generate_password)

# MySQL
MYSQL_ROOT_PASSWORD=$(generate_password)
MYSQL_DATABASE=devdb
MYSQL_USER=developer
MYSQL_PASSWORD=$(generate_password)
EOF

chmod 600 "$DOCKER_ENV_FILE"
print_success "Docker .env created: $DOCKER_ENV_FILE"

# ============================================================
# 2. Generate code-server password
# ============================================================
print_header "2. code-server Password Setup"

CODE_SERVER_PASSWORD=$(generate_password)
CODE_SERVER_CONFIG="$HOME/.config/code-server/config.yaml"

if [ ! -d "$HOME/.config/code-server" ]; then
    mkdir -p "$HOME/.config/code-server"
fi

if [ -f "$CODE_SERVER_CONFIG" ]; then
    print_warning "code-server config exists. Backing up..."
    cp "$CODE_SERVER_CONFIG" "${CODE_SERVER_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
fi

cat > "$CODE_SERVER_CONFIG" << EOF
# code-server configuration
# Generated: $(date)
# SECURITY: Keep this file secure!

bind-addr: 0.0.0.0:8443
auth: password
password: ${CODE_SERVER_PASSWORD}
cert: true
disable-telemetry: true
EOF

chmod 600 "$CODE_SERVER_CONFIG"
print_success "code-server config created: $CODE_SERVER_CONFIG"

# ============================================================
# 3. Summary
# ============================================================
print_header "🔐 Security Setup Complete!"

echo ""
echo -e "${GREEN}Generated Credentials:${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}code-server password:${NC}"
echo "  $CODE_SERVER_PASSWORD"
echo ""
echo -e "${YELLOW}Docker passwords are in:${NC}"
echo "  $DOCKER_ENV_FILE"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo -e "${RED}IMPORTANT:${NC}"
echo "  1. Save these passwords securely (password manager)"
echo "  2. Never commit .env files to git"
echo "  3. Restart services to apply new passwords:"
echo ""
echo "     sudo systemctl restart code-server"
echo "     cd docker && docker-compose down && docker-compose up -d"
echo ""
