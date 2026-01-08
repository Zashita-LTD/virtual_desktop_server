#!/bin/bash
#
# Storage Setup Script
# Creates directory structure for workspaces and projects
#
# Usage: sudo bash scripts/install/02-storage-setup.sh
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

log "Setting up storage structure..."

# Create main directories
log "Creating /data/shared/projects directory..."
mkdir -p /data/shared/projects

# Create workspace directories
log "Creating workspace directories..."
mkdir -p /data/shared/projects/workspace1-frontend
mkdir -p /data/shared/projects/workspace2-backend
mkdir -p /data/shared/projects/workspace3-ai-ml
mkdir -p /data/shared/projects/workspace4-infrastructure
mkdir -p /data/shared/projects/workspace5-experiments

# Create .vscode directories with settings
log "Creating workspace .vscode directories..."
for workspace in workspace1-frontend workspace2-backend workspace3-ai-ml workspace4-infrastructure workspace5-experiments; do
    mkdir -p "/data/shared/projects/$workspace/.vscode"
done

# Create README files for each workspace
log "Creating README files for workspaces..."

cat > /data/shared/projects/workspace1-frontend/README.md << 'EOF'
# Frontend Development Workspace

This workspace is for frontend development projects.

## Recommended for:
- React, Vue.js, Angular applications
- Static websites (HTML/CSS/JavaScript)
- Component libraries
- UI/UX prototypes

## Getting Started

1. Clone your frontend project here
2. Open the workspace file: `config/workspaces/workspace1-frontend.code-workspace`
3. Start developing!

## Tools Available
- Node.js v20 LTS
- npm, yarn, pnpm
- ESLint, Prettier
- Live Server extension
EOF

cat > /data/shared/projects/workspace2-backend/README.md << 'EOF'
# Backend Development Workspace

This workspace is for backend development projects.

## Recommended for:
- Node.js servers (Express, Fastify, NestJS)
- Python web applications (Django, Flask, FastAPI)
- Go servers
- REST APIs, GraphQL APIs

## Getting Started

1. Clone your backend project here
2. Open the workspace file: `config/workspaces/workspace2-backend.code-workspace`
3. Start developing!

## Tools Available
- Node.js v20 LTS
- Python 3.12+
- Go 1.21+
- Docker
EOF

cat > /data/shared/projects/workspace3-ai-ml/README.md << 'EOF'
# AI/ML Development Workspace

This workspace is for AI and Machine Learning projects.

## Recommended for:
- Machine Learning models
- Data Science projects
- Jupyter notebooks
- TensorFlow/PyTorch projects
- Vertex AI integrations

## Getting Started

1. Clone your AI/ML project here
2. Open the workspace file: `config/workspaces/workspace3-ai-ml.code-workspace`
3. Start developing!

## Tools Available
- Python 3.12+
- Vertex AI SDK
- Gemini API
- Jupyter support
EOF

cat > /data/shared/projects/workspace4-infrastructure/README.md << 'EOF'
# Infrastructure Workspace

This workspace is for DevOps and infrastructure projects.

## Recommended for:
- Terraform configurations
- Kubernetes manifests
- Docker configurations
- CI/CD pipelines
- Ansible playbooks

## Getting Started

1. Clone your infrastructure project here
2. Open the workspace file: `config/workspaces/workspace4-infrastructure.code-workspace`
3. Start developing!

## Tools Available
- Terraform
- Docker
- kubectl (Kubernetes CLI)
- gcloud CLI
EOF

cat > /data/shared/projects/workspace5-experiments/README.md << 'EOF'
# Experiments Workspace

This workspace is for experimental and learning projects.

## Recommended for:
- Proof of concepts
- Learning new technologies
- Quick prototypes
- Temporary projects

## Getting Started

1. Create your experimental project here
2. Open the workspace file: `config/workspaces/workspace5-experiments.code-workspace`
3. Experiment away!

## Note
This workspace is for temporary work. Move completed projects to appropriate workspaces.
EOF

# Create backup directory
log "Creating backup directory..."
mkdir -p /backup

# Set ownership to actual user
log "Setting ownership to $ACTUAL_USER..."
chown -R "$ACTUAL_USER:$ACTUAL_USER" /data/shared/projects
chown -R "$ACTUAL_USER:$ACTUAL_USER" /backup

# Set permissions
log "Setting permissions..."
chmod -R 755 /data/shared/projects
chmod -R 755 /backup

log_success "Storage structure created successfully!"
log "Created workspaces:"
log "  - /data/shared/projects/workspace1-frontend"
log "  - /data/shared/projects/workspace2-backend"
log "  - /data/shared/projects/workspace3-ai-ml"
log "  - /data/shared/projects/workspace4-infrastructure"
log "  - /data/shared/projects/workspace5-experiments"
log "Created backup directory: /backup"
