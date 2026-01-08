#!/bin/bash
#
# Backup Script
# Creates compressed backup of projects directory
#
# Usage: sudo bash scripts/management/backup.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/backup}"
SOURCE_DIR="/data/shared/projects"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/projects_$TIMESTAMP.tar.gz"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"

log "Starting backup process..."

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_error "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Calculate source size
SOURCE_SIZE=$(du -sh "$SOURCE_DIR" | cut -f1)
log "Source directory size: $SOURCE_SIZE"

# Check available disk space
AVAILABLE_SPACE=$(df -h "$BACKUP_DIR" | tail -1 | awk '{print $4}')
log "Available space in $BACKUP_DIR: $AVAILABLE_SPACE"

# Create backup
log "Creating backup: $BACKUP_FILE"
if tar -czf "$BACKUP_FILE" -C "$(dirname $SOURCE_DIR)" "$(basename $SOURCE_DIR)" 2>/dev/null; then
    BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    log_success "Backup created successfully: $BACKUP_FILE ($BACKUP_SIZE)"
else
    log_error "Failed to create backup"
    exit 1
fi

# Rotate old backups
log "Rotating old backups (keeping last $RETENTION_DAYS days)..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "projects_*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    log "Deleted $DELETED_COUNT old backup(s)"
else
    log "No old backups to delete"
fi

# List current backups
log "Current backups:"
ls -lh "$BACKUP_DIR"/projects_*.tar.gz 2>/dev/null || log "No backups found"

log_success "Backup process completed!"
