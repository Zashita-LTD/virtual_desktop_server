# Quick Start Guide

**Get your Virtual Desktop Server running in under 30 minutes!**

## Prerequisites

- Ubuntu 24.04 LTS server (GCP instance: instance-20260108-153942)
- SSH access to the server
- Sudo privileges

## Installation (5 Simple Steps)

### Step 1: SSH into the server

```bash
ssh vik9541@34.46.96.77
# or
gcloud compute ssh instance-20260108-153942 --zone=us-central1-c
```

### Step 2: Clone the repository

```bash
cd ~
git clone https://github.com/Zashita-LTD/virtual_desktop_server.git
cd virtual_desktop_server
```

### Step 3: Configure environment (optional)

```bash
cp .env.example .env
nano .env  # Edit if needed
```

### Step 4: Run the installation

```bash
sudo bash scripts/install/00-master-install.sh
```

⏱️ **This will take 15-30 minutes.** The script will:
- Update system packages
- Install code-server
- Install development tools (Git, Docker, Node.js, Python, Go, Rust)
- Install Google Cloud SDK
- Configure security (UFW, fail2ban)
- Set up monitoring and backups

### Step 5: Access code-server

1. Get the password:
```bash
cat ~/.config/code-server/config.yaml | grep password
```

2. Open in browser:
```
https://34.46.96.77:8443
```

3. Accept the self-signed certificate warning
4. Enter the password from step 1
5. **You're ready to code!** 🎉

## First Steps After Installation

### Open a Workspace

1. In code-server: **File → Open Workspace from File...**
2. Navigate to one of:
   - `/data/shared/projects/config/workspaces/workspace1-frontend.code-workspace`
   - `/data/shared/projects/config/workspaces/workspace2-backend.code-workspace`
   - `/data/shared/projects/config/workspaces/workspace3-ai-ml.code-workspace`
   - `/data/shared/projects/config/workspaces/workspace4-infrastructure.code-workspace`
   - `/data/shared/projects/config/workspaces/workspace5-experiments.code-workspace`

### Set up Git

```bash
bash scripts/workspaces/setup-git-config.sh
```

### Install GitHub Copilot (optional)

1. In code-server: **Extensions (Ctrl+Shift+X)**
2. Search for "GitHub Copilot"
3. Install
4. Sign in with your GitHub account

### Start a Terminal

In code-server: **Terminal → New Terminal** (or Ctrl+\`)

## Common Tasks

### Check System Health

```bash
bash scripts/management/health-check.sh
```

### Create a Backup

```bash
sudo bash scripts/management/backup.sh
```

### Update All Components

```bash
sudo bash scripts/management/update-all.sh
```

### Create a New Workspace

```bash
bash scripts/workspaces/create-workspace.sh workspace6-mobile
```

### Test Google Cloud AI

```bash
# Test Vertex AI
python3 scripts/ai-helpers/test-vertex-ai.py

# Test Gemini API (requires API key)
export GOOGLE_API_KEY="your-key"
python3 scripts/ai-helpers/test-gemini.py
```

## Troubleshooting

### Can't connect to code-server?

```bash
# Check if it's running
sudo systemctl status code-server

# Restart it
sudo systemctl restart code-server

# Check firewall
sudo ufw status
```

### Forgot password?

```bash
cat ~/.config/code-server/config.yaml | grep password
```

### Need help?

See the full documentation:
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Detailed deployment guide
- **[docs/troubleshooting.md](docs/troubleshooting.md)** - Common issues
- **[docs/user-guide.md](docs/user-guide.md)** - Complete user guide

## What's Next?

1. **Clone your projects** into the workspace directories
2. **Install extensions** specific to your work
3. **Set up tmux** for persistent sessions
4. **Configure Google Cloud** credentials
5. **Start developing!**

## Support

For issues or questions:
- Check **[docs/troubleshooting.md](docs/troubleshooting.md)**
- Run **health-check.sh** to diagnose issues
- Review logs: `journalctl -u code-server -n 100`

---

**Happy Coding! 🚀**
