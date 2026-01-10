#!/bin/bash
#
# Quick Terraform Setup Script
# Downloads Google provider offline for systems with IPv6 issues
#
# Usage: bash terraform/setup-terraform.sh
#

set -euo pipefail

PROVIDER_VERSION="5.45.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${SCRIPT_DIR}/terraform.d/plugins/registry.terraform.io/hashicorp/google/${PROVIDER_VERSION}"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

echo "🔧 Setting up Terraform for ${OS}_${ARCH}..."

# Create plugin directory
mkdir -p "${PLUGIN_DIR}/${OS}_${ARCH}"

# Download provider
PROVIDER_URL="https://releases.hashicorp.com/terraform-provider-google/${PROVIDER_VERSION}/terraform-provider-google_${PROVIDER_VERSION}_${OS}_${ARCH}.zip"
echo "📥 Downloading Google provider v${PROVIDER_VERSION}..."

cd "${PLUGIN_DIR}/${OS}_${ARCH}"
curl -sLO "$PROVIDER_URL"
unzip -o "terraform-provider-google_${PROVIDER_VERSION}_${OS}_${ARCH}.zip"
rm "terraform-provider-google_${PROVIDER_VERSION}_${OS}_${ARCH}.zip"

echo "✅ Provider downloaded to ${PLUGIN_DIR}/${OS}_${ARCH}"

# Initialize Terraform
cd "$SCRIPT_DIR"
echo "🚀 Initializing Terraform..."
terraform init -plugin-dir="terraform.d/plugins"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              ✅ Terraform Setup Complete!                     ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  Next steps:                                                  ║"
echo "║                                                               ║"
echo "║  1. Authenticate with GCP:                                    ║"
echo "║     gcloud auth application-default login                    ║"
echo "║                                                               ║"
echo "║  2. Copy terraform.tfvars:                                    ║"
echo "║     cp terraform.tfvars.example terraform.tfvars             ║"
echo "║     # Edit terraform.tfvars with your SSH key                ║"
echo "║                                                               ║"
echo "║  3. Plan deployment:                                          ║"
echo "║     terraform plan                                           ║"
echo "║                                                               ║"
echo "║  4. Apply deployment:                                         ║"
echo "║     terraform apply                                          ║"
echo "║                                                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
