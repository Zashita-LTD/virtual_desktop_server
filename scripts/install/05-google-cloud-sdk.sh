#!/bin/bash
#
# Google Cloud SDK Installation Script
# Installs gcloud CLI and AI libraries
#
# Usage: sudo bash scripts/install/05-google-cloud-sdk.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}

log "Installing Google Cloud SDK..."

# Add Google Cloud SDK repository
log "Adding Google Cloud SDK repository..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Install gcloud CLI
log "Installing gcloud CLI..."
apt update
apt install -y google-cloud-cli

# Install Python AI libraries
log "Installing Python AI libraries..."
sudo -u "$ACTUAL_USER" pip3 install --user \
    google-cloud-aiplatform \
    google-generativeai \
    vertexai \
    google-cloud-vision \
    google-cloud-language \
    google-cloud-translate

# Install Node.js AI libraries
log "Installing Node.js AI libraries..."
sudo -u "$ACTUAL_USER" npm install -g \
    @google-cloud/aiplatform \
    @google/generative-ai

log_success "Google Cloud SDK installation completed!"
log ""
log "Installed components:"
log "  - gcloud CLI $(gcloud --version | head -n1)"
log "  - Python AI libraries (google-cloud-aiplatform, vertexai, etc.)"
log "  - Node.js AI libraries (@google-cloud/aiplatform, etc.)"
log ""
log "Next steps:"
log "  1. Authenticate with Google Cloud:"
log "     gcloud auth login"
log "     OR"
log "     gcloud auth activate-service-account --key-file=/path/to/key.json"
log ""
log "  2. Set default project:"
log "     gcloud config set project viktor-integration"
log ""
log "  3. Enable required APIs:"
log "     gcloud services enable aiplatform.googleapis.com"
log "     gcloud services enable generativelanguage.googleapis.com"
log ""
log "  4. Test Vertex AI:"
log "     python3 scripts/ai-helpers/test-vertex-ai.py"
