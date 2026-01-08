#!/bin/bash
#
# Master Installation Script for Virtual Desktop Server
# Orchestrates all installation steps
#
# Usage: sudo bash scripts/install/00-master-install.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Get the actual user (not root if using sudo)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log "════════════════════════════════════════════════════════════════"
log "  🚀 Virtual Desktop Server Installation"
log "════════════════════════════════════════════════════════════════"
log "  User: $ACTUAL_USER"
log "  Home: $ACTUAL_HOME"
log "  Script Dir: $SCRIPT_DIR"
log "════════════════════════════════════════════════════════════════"

# Confirm before proceeding
read -p "This will install and configure the entire system. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Installation cancelled by user"
    exit 0
fi

# Track installation progress
FAILED_STEPS=()

run_step() {
    local step_num=$1
    local step_name=$2
    local step_script=$3
    
    log ""
    log "╔══════════════════════════════════════════════════════════════╗"
    log "║  Step $step_num: $step_name"
    log "╚══════════════════════════════════════════════════════════════╝"
    
    if [[ ! -f "$step_script" ]]; then
        log_error "Script not found: $step_script"
        FAILED_STEPS+=("$step_num: $step_name (script not found)")
        return 1
    fi
    
    # Make script executable
    chmod +x "$step_script"
    
    # Run the script
    if bash "$step_script"; then
        log_success "Step $step_num completed: $step_name"
        return 0
    else
        log_error "Step $step_num failed: $step_name"
        FAILED_STEPS+=("$step_num: $step_name")
        return 1
    fi
}

# Run installation steps
START_TIME=$(date +%s)

# Step 1: System Preparation
run_step 1 "System Preparation" "$SCRIPT_DIR/01-system-prep.sh"

# Step 2: Storage Setup
run_step 2 "Storage Setup" "$SCRIPT_DIR/02-storage-setup.sh"

# Step 3: code-server Installation
run_step 3 "code-server Installation" "$SCRIPT_DIR/03-code-server-install.sh"

# Step 4: Development Tools
run_step 4 "Development Tools" "$SCRIPT_DIR/04-dev-tools.sh"

# Step 5: Google Cloud SDK
run_step 5 "Google Cloud SDK" "$SCRIPT_DIR/05-google-cloud-sdk.sh"

# Step 6: Security Setup
run_step 6 "Security Setup" "$SCRIPT_DIR/06-security-setup.sh"

# Step 7: Monitoring Setup
run_step 7 "Monitoring Setup" "$SCRIPT_DIR/07-monitoring-setup.sh"

# Calculate installation time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Summary
log ""
log "════════════════════════════════════════════════════════════════"
log "  Installation Summary"
log "════════════════════════════════════════════════════════════════"

if [ ${#FAILED_STEPS[@]} -eq 0 ]; then
    log_success "All installation steps completed successfully! 🎉"
    log ""
    log "Installation time: ${MINUTES}m ${SECONDS}s"
    log ""
    log "Next steps:"
    log "  1. Get code-server password:"
    log "     cat ~/.config/code-server/config.yaml | grep password"
    log ""
    log "  2. Open code-server in your browser:"
    log "     https://34.46.96.77:8443"
    log ""
    log "  3. Accept the self-signed certificate warning"
    log ""
    log "  4. Enter the password from step 1"
    log ""
    log "  5. Open a workspace:"
    log "     File → Open Workspace from File..."
    log "     Select from /data/shared/projects/config/workspaces/"
    log ""
    log "  6. Check system health:"
    log "     sudo bash scripts/management/health-check.sh"
    log ""
    log "════════════════════════════════════════════════════════════════"
    log_success "Virtual Desktop Server is ready! 🚀"
    log "════════════════════════════════════════════════════════════════"
else
    log_warning "Installation completed with ${#FAILED_STEPS[@]} failed step(s)"
    log ""
    log "Failed steps:"
    for step in "${FAILED_STEPS[@]}"; do
        log_error "  - $step"
    done
    log ""
    log "Please review the logs above and fix the issues."
    log "You can re-run individual scripts from $SCRIPT_DIR/"
    log ""
    log "Installation time: ${MINUTES}m ${SECONDS}s"
    log "════════════════════════════════════════════════════════════════"
    exit 1
fi
