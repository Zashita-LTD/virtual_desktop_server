#!/bin/bash
#
# Automated Backup Script with GCS Support
# Backs up workspaces, configs, and databases to Google Cloud Storage
#
# Usage: sudo bash scripts/management/backup-gcs.sh
#
# Cron example (daily at 3 AM):
#   0 3 * * * /opt/virtual_desktop_server/scripts/management/backup-gcs.sh >> /var/log/backup.log 2>&1
#

set -euo pipefail

# Configuration
BACKUP_DIR="/backup"
GCS_BUCKET="${GCS_BACKUP_BUCKET:-gs://virtual-desktop-backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname)
BACKUP_NAME="backup_${HOSTNAME}_${TIMESTAMP}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI not found. Please install Google Cloud SDK."
    exit 1
fi

# Create backup directory
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"
cd "${BACKUP_DIR}/${BACKUP_NAME}"

log "Starting backup: ${BACKUP_NAME}"

# ============================================================
# 1. Backup Workspaces
# ============================================================
log "Backing up workspaces..."

if [ -d "/data/shared/projects" ]; then
    tar -czf workspaces.tar.gz \
        --exclude='node_modules' \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='.venv' \
        --exclude='venv' \
        --exclude='.cache' \
        --exclude='dist' \
        --exclude='build' \
        -C /data/shared projects
    log_success "Workspaces backed up: $(du -h workspaces.tar.gz | cut -f1)"
else
    log "No workspaces directory found at /data/shared/projects"
fi

# ============================================================
# 2. Backup code-server config
# ============================================================
log "Backing up code-server configuration..."

USERNAME="${USERNAME:-vik9541}"
if [ -d "/home/${USERNAME}/.config/code-server" ]; then
    tar -czf code-server-config.tar.gz -C "/home/${USERNAME}/.config" code-server
    log_success "code-server config backed up"
fi

if [ -d "/home/${USERNAME}/.local/share/code-server" ]; then
    tar -czf code-server-data.tar.gz \
        --exclude='CachedExtensionVSIXs' \
        --exclude='logs' \
        -C "/home/${USERNAME}/.local/share" code-server
    log_success "code-server data backed up"
fi

# ============================================================
# 3. Backup Docker volumes (PostgreSQL, etc.)
# ============================================================
log "Backing up Docker volumes..."

if command -v docker &> /dev/null && docker ps -q &> /dev/null; then
    # PostgreSQL dump
    if docker ps --format '{{.Names}}' | grep -q "dev_postgres"; then
        log "Dumping PostgreSQL..."
        docker exec dev_postgres pg_dumpall -U developer > postgres_dump.sql
        gzip postgres_dump.sql
        log_success "PostgreSQL dumped"
    fi
    
    # MongoDB dump
    if docker ps --format '{{.Names}}' | grep -q "dev_mongodb"; then
        log "Dumping MongoDB..."
        docker exec dev_mongodb mongodump --archive --gzip > mongodb_dump.gz
        log_success "MongoDB dumped"
    fi
    
    # Redis dump
    if docker ps --format '{{.Names}}' | grep -q "dev_redis"; then
        log "Dumping Redis..."
        docker exec dev_redis redis-cli BGSAVE
        sleep 2
        docker cp dev_redis:/data/dump.rdb redis_dump.rdb 2>/dev/null || true
        log_success "Redis dumped"
    fi
fi

# ============================================================
# 4. Backup system configs
# ============================================================
log "Backing up system configurations..."

mkdir -p system_configs
cp /etc/systemd/system/code-server.service system_configs/ 2>/dev/null || true
cp -r /etc/fail2ban/jail.d system_configs/ 2>/dev/null || true
cp -r /etc/nginx/sites-available system_configs/ 2>/dev/null || true

if [ -d "system_configs" ] && [ "$(ls -A system_configs)" ]; then
    tar -czf system-configs.tar.gz system_configs
    rm -rf system_configs
    log_success "System configs backed up"
fi

# ============================================================
# 5. Create backup manifest
# ============================================================
log "Creating backup manifest..."

cat > manifest.json << EOF
{
    "backup_name": "${BACKUP_NAME}",
    "timestamp": "${TIMESTAMP}",
    "hostname": "${HOSTNAME}",
    "date": "$(date -Iseconds)",
    "files": $(ls -la | tail -n +4 | awk '{print "\"" $9 "\": \"" $5 " bytes\""}' | paste -sd, | sed 's/^/{/;s/$/}/'),
    "total_size": "$(du -sh . | cut -f1)"
}
EOF

log_success "Manifest created"

# ============================================================
# 6. Create final archive
# ============================================================
log "Creating final archive..."

cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

FINAL_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
log_success "Final backup archive: ${BACKUP_NAME}.tar.gz (${FINAL_SIZE})"

# ============================================================
# 7. Upload to GCS
# ============================================================
log "Uploading to Google Cloud Storage..."

if gsutil ls "${GCS_BUCKET}" &> /dev/null; then
    gsutil cp "${BACKUP_NAME}.tar.gz" "${GCS_BUCKET}/daily/"
    log_success "Uploaded to ${GCS_BUCKET}/daily/${BACKUP_NAME}.tar.gz"
else
    log_error "GCS bucket ${GCS_BUCKET} not accessible. Backup stored locally only."
fi

# ============================================================
# 8. Cleanup old backups
# ============================================================
log "Cleaning up old backups..."

# Local cleanup
find "${BACKUP_DIR}" -name "backup_*.tar.gz" -mtime +${RETENTION_DAYS} -delete
log_success "Local backups older than ${RETENTION_DAYS} days removed"

# GCS cleanup
if gsutil ls "${GCS_BUCKET}" &> /dev/null; then
    CUTOFF_DATE=$(date -d "${RETENTION_DAYS} days ago" +%Y%m%d)
    gsutil ls "${GCS_BUCKET}/daily/backup_*.tar.gz" 2>/dev/null | while read -r file; do
        FILE_DATE=$(echo "$file" | grep -oP '\d{8}' | head -1)
        if [[ "$FILE_DATE" < "$CUTOFF_DATE" ]]; then
            gsutil rm "$file"
            log "Removed old GCS backup: $file"
        fi
    done
fi

# ============================================================
# Summary
# ============================================================
log_success "Backup completed successfully!"
log "  Local: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
log "  GCS: ${GCS_BUCKET}/daily/${BACKUP_NAME}.tar.gz"
log "  Size: ${FINAL_SIZE}"
log "  Retention: ${RETENTION_DAYS} days"
