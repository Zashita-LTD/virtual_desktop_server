#!/bin/bash
#
# Create Workspace Script
# Creates a new workspace with basic structure
#
# Usage: bash scripts/workspaces/create-workspace.sh workspace-name
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

# Check arguments
if [ $# -eq 0 ]; then
    log_error "Usage: $0 workspace-name"
    log "Example: $0 workspace6-mobile"
    exit 1
fi

WORKSPACE_NAME="$1"
WORKSPACE_DIR="/data/shared/projects/$WORKSPACE_NAME"
CONFIG_DIR="$HOME/virtual_desktop_server/config/workspaces"

log "Creating new workspace: $WORKSPACE_NAME"

# Check if workspace already exists
if [ -d "$WORKSPACE_DIR" ]; then
    log_error "Workspace directory already exists: $WORKSPACE_DIR"
    exit 1
fi

# Create workspace directory
log "Creating workspace directory..."
mkdir -p "$WORKSPACE_DIR/.vscode"

# Create VS Code settings
log "Creating VS Code settings..."
cat > "$WORKSPACE_DIR/.vscode/settings.json" << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.tabSize": 2,
  "files.autoSave": "afterDelay",
  "files.exclude": {
    "**/node_modules": true,
    "**/.git": true,
    "**/dist": true,
    "**/__pycache__": true,
    "**/.venv": true
  }
}
EOF

# Create README
log "Creating README..."
cat > "$WORKSPACE_DIR/README.md" << EOF
# $WORKSPACE_NAME

Created: $(date)

## Description

Add your workspace description here.

## Getting Started

1. Clone your project(s) into this directory
2. Open the workspace file in code-server
3. Start developing!

## Projects

- [Add your projects here]
EOF

# Create .code-workspace file
log "Creating .code-workspace file..."
mkdir -p "$CONFIG_DIR"
WORKSPACE_FILE="$CONFIG_DIR/$WORKSPACE_NAME.code-workspace"

cat > "$WORKSPACE_FILE" << EOF
{
  "folders": [
    {
      "name": "$WORKSPACE_NAME",
      "path": "$WORKSPACE_DIR"
    }
  ],
  "settings": {
    "editor.formatOnSave": true,
    "files.autoSave": "afterDelay"
  },
  "extensions": {
    "recommendations": [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode",
      "eamodio.gitlens"
    ]
  }
}
EOF

log_success "Workspace created successfully!"
log ""
log "Workspace directory: $WORKSPACE_DIR"
log "Workspace file: $WORKSPACE_FILE"
log ""
log "Next steps:"
log "  1. Open code-server in browser"
log "  2. File → Open Workspace from File..."
log "  3. Navigate to: $WORKSPACE_FILE"
log "  4. Start adding projects to $WORKSPACE_DIR"
