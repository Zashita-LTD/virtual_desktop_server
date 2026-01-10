# Quick Terraform Setup Script (Windows PowerShell)
# Downloads Google provider offline for systems with registry issues
#
# Usage: .\terraform\setup-terraform.ps1

$ErrorActionPreference = "Stop"

$PROVIDER_VERSION = "5.45.0"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PLUGIN_DIR = "$SCRIPT_DIR\terraform.d\plugins\registry.terraform.io\hashicorp\google\$PROVIDER_VERSION\windows_amd64"

Write-Host "🔧 Setting up Terraform for windows_amd64..." -ForegroundColor Cyan

# Create plugin directory
New-Item -ItemType Directory -Force -Path $PLUGIN_DIR | Out-Null

# Download provider
$PROVIDER_URL = "https://releases.hashicorp.com/terraform-provider-google/$PROVIDER_VERSION/terraform-provider-google_${PROVIDER_VERSION}_windows_amd64.zip"
Write-Host "📥 Downloading Google provider v$PROVIDER_VERSION..." -ForegroundColor Yellow

$zipPath = "$PLUGIN_DIR\provider.zip"
Invoke-WebRequest -Uri $PROVIDER_URL -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $PLUGIN_DIR -Force
Remove-Item $zipPath

Write-Host "✅ Provider downloaded to $PLUGIN_DIR" -ForegroundColor Green

# Initialize Terraform
Set-Location $SCRIPT_DIR
Write-Host "🚀 Initializing Terraform..." -ForegroundColor Cyan
terraform init -plugin-dir="terraform.d\plugins"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              ✅ Terraform Setup Complete!                     ║" -ForegroundColor Green
Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║  Next steps:                                                  ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║  1. Authenticate with GCP:                                    ║" -ForegroundColor Green
Write-Host "║     gcloud auth application-default login                    ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║  2. Copy terraform.tfvars:                                    ║" -ForegroundColor Green
Write-Host "║     copy terraform.tfvars.example terraform.tfvars           ║" -ForegroundColor Green
Write-Host "║     # Edit terraform.tfvars with your SSH key                ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║  3. Plan deployment:                                          ║" -ForegroundColor Green
Write-Host "║     terraform plan                                           ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║  4. Apply deployment:                                         ║" -ForegroundColor Green
Write-Host "║     terraform apply                                          ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
