#!/bin/bash
#
# Setup Git Configuration Script
# Configures Git for the user
#
# Usage: bash scripts/workspaces/setup-git-config.sh
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

log "Setting up Git configuration..."

# Check if Git is installed
if ! command -v git &> /dev/null; then
    log_warning "Git is not installed!"
    exit 1
fi

# Get current configuration
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
    log "Current Git configuration:"
    log "  Name: $CURRENT_NAME"
    log "  Email: $CURRENT_EMAIL"
    echo ""
    read -p "Do you want to update this configuration? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Keeping current configuration"
        exit 0
    fi
fi

# Get user name
echo ""
read -p "Enter your name (e.g., 'John Doe'): " GIT_NAME
while [ -z "$GIT_NAME" ]; do
    read -p "Name cannot be empty. Enter your name: " GIT_NAME
done

# Get user email
read -p "Enter your email (e.g., 'john@example.com'): " GIT_EMAIL
while [ -z "$GIT_EMAIL" ]; do
    read -p "Email cannot be empty. Enter your email: " GIT_EMAIL
done

# Set Git configuration
log "Configuring Git..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Set additional useful defaults
log "Setting additional Git defaults..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "code-server --wait"
git config --global credential.helper store

# Optional: Setup SSH key for GitHub
echo ""
read -p "Do you want to generate an SSH key for GitHub? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        log "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N ""
        
        log_success "SSH key generated!"
        log ""
        log "Your public SSH key:"
        echo "════════════════════════════════════════════════════════════════"
        cat ~/.ssh/id_ed25519.pub
        echo "════════════════════════════════════════════════════════════════"
        log ""
        log "To add this key to GitHub:"
        log "  1. Go to https://github.com/settings/keys"
        log "  2. Click 'New SSH key'"
        log "  3. Paste the key above"
        log "  4. Test with: ssh -T git@github.com"
    else
        log_warning "SSH key already exists at ~/.ssh/id_ed25519"
        log "Your public key:"
        cat ~/.ssh/id_ed25519.pub
    fi
fi

# Optional: Setup GitHub CLI
echo ""
read -p "Do you want to authenticate GitHub CLI (gh)? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v gh &> /dev/null; then
        log "Starting GitHub CLI authentication..."
        gh auth login
    else
        log_warning "GitHub CLI (gh) is not installed"
    fi
fi

log_success "Git configuration completed!"
log ""
log "Current configuration:"
git config --global --list | grep user
log ""
log "To verify GitHub SSH access:"
log "  ssh -T git@github.com"
log ""
log "To verify GitHub CLI:"
log "  gh auth status"
