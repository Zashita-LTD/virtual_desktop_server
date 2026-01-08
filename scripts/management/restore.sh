#!/bin/bash
#
# Restore Script
# Restores projects from backup archive
#
# Usage: sudo bash scripts/management/restore.sh /path/to/backup.tar.gz
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

# Check arguments
if [ $# -eq 0 ]; then
    log_error "Usage: $0 /path/to/backup.tar.gz"
    log "Available backups:"
    ls -lh /backup/projects_*.tar.gz 2>/dev/null || log "No backups found in /backup/"
    exit 1
fi

BACKUP_FILE="$1"
RESTORE_DIR="/data/shared/projects"
ACTUAL_USER=${SUDO_USER:-$USER}

log "Starting restore process..."

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    log_error "Backup file does not exist: $BACKUP_FILE"
    exit 1
fi

# Verify it's a valid tar.gz
log "Verifying backup archive..."
if ! tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    log_error "Invalid or corrupted backup file: $BACKUP_FILE"
    exit 1
fi

log_success "Backup archive is valid"

# Show backup contents
log "Backup contents:"
tar -tzf "$BACKUP_FILE" | head -10
echo "..."

# Confirm before proceeding
log_warning "This will replace current projects directory!"
log "Current directory: $RESTORE_DIR"
log "Backup file: $BACKUP_FILE"
read -p "Continue with restore? (yes/NO) " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log "Restore cancelled by user"
    exit 0
fi

# Stop code-server
log "Stopping code-server..."
systemctl stop code-server || log_warning "code-server was not running"

# Create backup of current state
if [ -d "$RESTORE_DIR" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    SAFETY_BACKUP="/data/shared/projects.before_restore_$TIMESTAMP"
    log "Creating safety backup of current state: $SAFETY_BACKUP"
    mv "$RESTORE_DIR" "$SAFETY_BACKUP"
fi

# Create parent directory if needed
mkdir -p "$(dirname $RESTORE_DIR)"

# Extract backup
log "Extracting backup..."
if tar -xzf "$BACKUP_FILE" -C "$(dirname $RESTORE_DIR)"; then
    log_success "Backup extracted successfully"
else
    log_error "Failed to extract backup"
    
    # Try to restore from safety backup
    if [ -d "$SAFETY_BACKUP" ]; then
        log "Attempting to restore from safety backup..."
        mv "$SAFETY_BACKUP" "$RESTORE_DIR"
    fi
    
    exit 1
fi

# Set ownership
log "Setting ownership to $ACTUAL_USER..."
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$RESTORE_DIR"

# Set permissions
log "Setting permissions..."
chmod -R 755 "$RESTORE_DIR"

# Start code-server
log "Starting code-server..."
systemctl start code-server

# Wait and check status
sleep 3
if systemctl is-active --quiet code-server; then
    log_success "code-server started successfully"
else
    log_warning "code-server might not have started. Check: systemctl status code-server"
fi

log_success "Restore completed!"
log ""
log "Restored from: $BACKUP_FILE"
log "To: $RESTORE_DIR"
if [ -d "$SAFETY_BACKUP" ]; then
    log ""
    log "Previous state backed up to: $SAFETY_BACKUP"
    log "You can delete it if restore is successful:"
    log "  sudo rm -rf $SAFETY_BACKUP"
fi
