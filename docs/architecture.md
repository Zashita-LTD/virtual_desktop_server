# Архитектура Virtual Desktop Server

Подробное описание архитектуры системы, компонентов и их взаимодействия.

## 🏗️ Обзор архитектуры

```
                                    Internet
                                       │
                                       │
                          ┌────────────▼────────────┐
                          │    GCP Firewall         │
                          │  Ports: 22, 443, 8443   │
                          └────────────┬────────────┘
                                       │
                          ┌────────────▼────────────────────────────┐
                          │  GCP Instance: instance-20260108-153942 │
                          │  e2-highmem-8 (8 vCPU, 64 GB RAM)      │
                          │  Ubuntu 24.04 LTS                       │
                          │  500 GB SSD                             │
                          └────────────┬────────────────────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
    ┌───────────▼──────────┐  ┌───────▼────────┐  ┌─────────▼────────┐
    │   UFW Firewall       │  │  fail2ban      │  │  Cloud Ops Agent │
    │   (Host-level)       │  │  (Protection)  │  │  (Monitoring)    │
    └──────────────────────┘  └────────────────┘  └──────────────────┘
                                       │
                          ┌────────────▼────────────┐
                          │   systemd Services      │
                          │  - code-server          │
                          │  - docker               │
                          │  - backup.timer         │
                          └────────────┬────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
    ┌───────────▼──────────┐  ┌───────▼────────┐  ┌─────────▼────────┐
    │  code-server:8443    │  │  Docker Engine │  │  Local Storage   │
    │  (VS Code in Web)    │  │  Containers    │  │  /data/shared    │
    │                      │  │                │  │  /backup         │
    └──────────┬───────────┘  └────────────────┘  └──────────────────┘
               │
               │
    ┌──────────▼──────────────────────────────────────┐
    │         5 Workspaces (Multi-root)                │
    ├──────────────────────────────────────────────────┤
    │  1. Frontend    (React, Vue, Angular)            │
    │  2. Backend     (Node, Python, Go)               │
    │  3. AI/ML       (TensorFlow, Vertex AI)          │
    │  4. Infrastructure (Terraform, K8s)              │
    │  5. Experiments (Prototyping)                    │
    └──────────────────────────────────────────────────┘
                           │
                           │
    ┌──────────────────────▼────────────────────────┐
    │          Development Tools                     │
    ├────────────────────────────────────────────────┤
    │  • Git, GitHub CLI                             │
    │  • Node.js v20 + npm/yarn/pnpm                 │
    │  • Python 3.12 + pip/poetry                    │
    │  • Go 1.21+                                    │
    │  • Rust + Cargo                                │
    │  • Google Cloud SDK                            │
    │  • tmux, htop, btop                            │
    └────────────────────────────────────────────────┘
                           │
                           │
    ┌──────────────────────▼────────────────────────┐
    │         External Services                      │
    ├────────────────────────────────────────────────┤
    │  • GitHub (Version Control, Copilot)           │
    │  • Google Cloud AI (Vertex AI, Gemini)         │
    │  • GCP Cloud Monitoring                        │
    │  • GCP Cloud Logging                           │
    └────────────────────────────────────────────────┘
```

## 🔧 Основные компоненты

### 1. GCP Infrastructure

**Instance Specifications:**
- **Name:** instance-20260108-153942
- **Machine Type:** e2-highmem-8
  - 8 vCPU (Intel/AMD)
  - 64 GB RAM
  - 500 GB SSD (Boot disk)
- **Zone:** us-central1-c
- **Network:** Default VPC
- **External IP:** 34.46.96.77 (Static)
- **Service Account:** 763289222664-compute@developer.gserviceaccount.com

**Firewall Rules:**
```
Allow from 0.0.0.0/0:
  - TCP/22   (SSH)
  - TCP/443  (HTTPS - Nginx)
  - TCP/8443 (code-server)
```

### 2. Operating System

**Ubuntu 24.04 LTS (Noble Numbat)**
- Long-term support до 2029
- Kernel 6.x
- systemd для управления сервисами
- APT для управления пакетами
- snap для дополнительных пакетов

**Filesystem Layout:**
```
/                          # Root filesystem (500 GB)
├── /home/vik9541         # Home directory пользователя
├── /data/shared/         # Централизованное хранилище проектов
│   └── projects/         # 5 workspaces
├── /backup/              # Директория для бэкапов
├── /var/log/             # Системные логи
├── /etc/                 # Конфигурационные файлы
└── ~/.config/code-server # Конфигурация code-server
```

### 3. code-server

**Version:** 4.x (latest stable)

**Функции:**
- VS Code в браузере через HTTPS
- Полная совместимость с расширениями VS Code
- Multi-root workspace support
- Integrated terminal
- Git integration
- Debugging support

**Конфигурация:**
```yaml
# ~/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8443
auth: password
password: <auto-generated>
cert: true  # Self-signed or Let's Encrypt
```

**systemd Service:**
```ini
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=vik9541
ExecStart=/usr/bin/code-server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Расширения (pre-installed):**
- GitHub Copilot
- ESLint
- Prettier
- Python
- Go
- Docker
- Terraform
- GitLens

### 4. Workspaces

**Концепция:**
- 5 специализированных multi-root workspaces
- Каждый workspace для определенного типа проектов
- Изолированные настройки и расширения
- Общие dev tools и ресурсы

**Workspace 1: Frontend**
```
/data/shared/projects/workspace1-frontend/
├── .vscode/settings.json   # ESLint, Prettier, Live Server
├── README.md
└── [проекты пользователя]
```

**Workspace 2: Backend**
```
/data/shared/projects/workspace2-backend/
├── .vscode/settings.json   # Python, Go, REST Client
├── README.md
└── [проекты пользователя]
```

**Workspace 3: AI/ML**
```
/data/shared/projects/workspace3-ai-ml/
├── .vscode/settings.json   # Jupyter, Data Science
├── README.md
└── [проекты пользователя]
```

**Workspace 4: Infrastructure**
```
/data/shared/projects/workspace4-infrastructure/
├── .vscode/settings.json   # Terraform, Kubernetes, YAML
├── README.md
└── [проекты пользователя]
```

**Workspace 5: Experiments**
```
/data/shared/projects/workspace5-experiments/
├── .vscode/settings.json   # General purpose
├── README.md
└── [проекты пользователя]
```

### 5. Security Layer

**UFW (Uncomplicated Firewall):**
```bash
# Host-level firewall
Status: active
Rules:
  22/tcp    ALLOW  Anywhere  (SSH)
  443/tcp   ALLOW  Anywhere  (HTTPS)
  8443/tcp  ALLOW  Anywhere  (code-server)
```

**fail2ban:**
```ini
# Protection against brute-force attacks
[code-server]
enabled = true
port = 8443
maxretry = 5
bantime = 3600
findtime = 600
```

**SSL/TLS:**
- Self-signed certificates (development)
- Let's Encrypt certificates (production)
- HTTPS-only access to code-server
- Certificate auto-renewal (if using Let's Encrypt)

**Automatic Security Updates:**
```bash
# unattended-upgrades
- Security updates applied automatically
- Reboot if required (configurable)
- Email notifications on errors
```

### 6. Monitoring & Logging

**Google Cloud Ops Agent:**
```
Metrics collected:
- CPU usage (%)
- Memory usage (MB)
- Disk I/O (ops/sec)
- Network traffic (bytes/sec)
- Process count

Logs collected:
- syslog
- auth.log
- code-server logs
- Docker logs
- Application logs
```

**Local Monitoring Tools:**
- htop: Interactive process viewer
- btop: Modern resource monitor
- journalctl: systemd logs viewer
- docker stats: Container stats

**Alerting:**
- GCP Cloud Monitoring alerts
- Email notifications
- Slack integration (опционально)

### 7. Backup System

**Backup Strategy:**
```bash
Daily automatic backups via systemd timer
- Time: 02:00 AM daily
- Target: /data/shared/projects/
- Format: tar.gz
- Retention: 7 days
- Location: /backup/
```

**Backup Components:**
- User projects and files
- VS Code settings and extensions
- Git repositories (optional)
- Configuration files
- Databases (if any)

**Restore Process:**
```bash
1. Stop code-server
2. Extract backup
3. Restore files to original locations
4. Fix permissions
5. Start code-server
```

### 8. Development Tools Stack

**Version Control:**
- Git 2.x
- GitHub CLI (gh)
- GitLens (VS Code extension)

**Containers:**
- Docker Engine 24.x
- Docker Compose v2
- docker-compose.yml for common stacks

**Languages & Runtimes:**
```
Node.js v20 LTS
├── npm (default)
├── yarn
└── pnpm

Python 3.12+
├── pip
├── venv
└── poetry

Go 1.21+
└── go mod

Rust (latest stable)
└── cargo
```

**Build Tools:**
- gcc, g++
- make
- cmake
- build-essential

**Google Cloud AI:**
```
Python:
- google-cloud-aiplatform
- google-generativeai
- vertexai

Node.js:
- @google-cloud/aiplatform
- @google/generative-ai
```

**Utilities:**
- tmux: Terminal multiplexer
- screen: Terminal multiplexer alternative
- jq: JSON processor
- tree: Directory tree viewer
- ncdu: Disk usage analyzer

## 🔄 Data Flow

### 1. User Access Flow

```
User Browser
    │
    │ HTTPS (Port 8443)
    ▼
GCP Firewall
    │
    │ Allow TCP/8443
    ▼
UFW Firewall
    │
    │ Allow TCP/8443
    ▼
fail2ban Check
    │
    │ If not banned
    ▼
code-server
    │
    │ Password Authentication
    ▼
VS Code UI
    │
    │ Open Workspace
    ▼
Project Files (/data/shared/projects/)
```

### 2. Development Flow

```
Code Changes in Browser
    │
    ▼
Workspace Files (Auto-saved)
    │
    ├──▶ Git Commit (Local)
    │       │
    │       ▼
    │    GitHub Push
    │
    ├──▶ Docker Build (Local)
    │       │
    │       ▼
    │    Container Run
    │
    └──▶ Cloud Deployment
            │
            ▼
         GCP Services
```

### 3. Backup Flow

```
systemd timer (02:00 AM daily)
    │
    ▼
backup.sh script
    │
    ├──▶ tar.gz creation
    │       │
    │       ▼
    │    Save to /backup/
    │
    └──▶ Rotation (delete old)
            │
            ▼
         Keep last 7 days
```

### 4. Monitoring Flow

```
System Metrics
    │
    ▼
Cloud Ops Agent
    │
    ├──▶ Metrics → Cloud Monitoring
    │                   │
    │                   ▼
    │              Dashboards & Alerts
    │
    └──▶ Logs → Cloud Logging
                    │
                    ▼
               Log Analysis & Search
```

## 🚀 Performance Considerations

### Resource Allocation

**CPU (8 vCPU):**
- code-server: 1-2 vCPU
- Docker containers: 2-4 vCPU
- Build processes: 2-3 vCPU
- System overhead: 1 vCPU

**Memory (64 GB):**
- code-server: 2-4 GB
- Docker containers: 10-20 GB
- Node.js builds: 4-8 GB
- Python/ML: 10-20 GB
- System overhead: 2-4 GB
- Free buffer: 10+ GB

**Disk (500 GB SSD):**
- OS & System: 20 GB
- Docker images: 50-100 GB
- Projects: 100-200 GB
- Backups: 50-100 GB
- Free space: 100+ GB

### Optimization Tips

1. **Use Docker for heavy workloads**
   - Isolate resource-intensive builds
   - Limit container memory/CPU
   - Use docker-compose for orchestration

2. **Enable workspace caching**
   - npm/yarn cache
   - pip cache
   - Go module cache
   - Docker layer cache

3. **Monitor disk usage**
   - Regular cleanup of Docker images
   - Prune unused containers
   - Rotate logs properly
   - Clean build artifacts

4. **Optimize code-server**
   - Disable unused extensions
   - Limit workspace folders
   - Use .gitignore for large files
   - Enable TypeScript project references

## 🔐 Security Architecture

### Defense in Depth

**Layer 1: Network (GCP Firewall)**
- Restrict inbound to necessary ports only
- No outbound restrictions (for updates)

**Layer 2: Host (UFW)**
- Additional firewall layer
- Logging enabled
- Default deny policy

**Layer 3: Application (fail2ban)**
- Brute-force protection
- Automatic IP banning
- Whitelisting support

**Layer 4: Authentication**
- Strong password for code-server
- SSH key-based authentication
- Google Cloud IAM for API access

**Layer 5: Encryption**
- HTTPS for web access
- SSH for terminal access
- Encrypted backups (optional)

### Threat Model

**Threats Mitigated:**
- ✅ Brute-force attacks (fail2ban)
- ✅ Man-in-the-middle (HTTPS)
- ✅ Unauthorized access (passwords/keys)
- ✅ Port scanning (minimal exposed ports)
- ✅ Data loss (backups)

**Threats to Consider:**
- ⚠️ Compromised credentials (use 2FA where possible)
- ⚠️ Supply chain attacks (verify package sources)
- ⚠️ Zero-day exploits (keep system updated)
- ⚠️ Insider threats (audit logging)

## 🔄 Disaster Recovery

### Recovery Time Objective (RTO)

**Scenario 1: code-server failure**
- Detection: Immediate (systemd auto-restart)
- Recovery: < 1 minute
- Data loss: None

**Scenario 2: Disk corruption**
- Detection: Monitoring alerts
- Recovery: 30-60 minutes (restore from backup)
- Data loss: < 24 hours (last backup)

**Scenario 3: Instance failure**
- Detection: GCP monitoring
- Recovery: 1-2 hours (recreate instance + restore)
- Data loss: < 24 hours (last backup)

### Recovery Procedures

1. **Quick restart:** `sudo systemctl restart code-server`
2. **Restore from backup:** `bash scripts/management/restore.sh`
3. **Rebuild instance:** Run Terraform + master-install.sh
4. **Migrate to new instance:** Backup → Transfer → Restore

## 📊 Scalability

### Vertical Scaling (Current)

**Scaling Up:**
- Increase machine type (e2-highmem-16, e2-highcpu-32)
- Add more disk space (resize boot disk)
- More CPU/RAM for heavier workloads

### Horizontal Scaling (Future)

**Multi-User Setup:**
- Separate code-server instances per user
- Shared storage (NFS/GCS)
- Load balancer for multiple instances
- Container orchestration (Kubernetes)

**Current Design:**
- ✅ Single user (vik9541)
- ✅ Multiple projects/workspaces
- ✅ Shared resources
- ✅ Simple management

## 📚 Technology Stack Summary

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Infrastructure | Google Cloud Platform | - | Cloud hosting |
| OS | Ubuntu | 24.04 LTS | Operating system |
| IDE | code-server | 4.x | Web-based VS Code |
| Container | Docker | 24.x | Application containers |
| Languages | Node.js | 20 LTS | JavaScript runtime |
| Languages | Python | 3.12+ | Python runtime |
| Languages | Go | 1.21+ | Go runtime |
| Languages | Rust | latest | Rust runtime |
| Cloud SDK | gcloud | latest | GCP CLI |
| AI/ML | Vertex AI SDK | latest | Google AI platform |
| AI/ML | Gemini API | latest | Generative AI |
| Version Control | Git | 2.x | Source control |
| Firewall | UFW | - | Host firewall |
| Protection | fail2ban | - | Intrusion prevention |
| Monitoring | Cloud Ops Agent | latest | Metrics & logs |
| Backup | systemd timer | - | Scheduled backups |
| Terminal | tmux | 3.x | Terminal multiplexer |

## 🎓 Best Practices

### Code Organization

1. **Use workspaces for logical separation**
   - Frontend projects in workspace1
   - Backend projects in workspace2
   - etc.

2. **Keep projects in /data/shared/projects/**
   - Centralized location
   - Easy to backup
   - Consistent structure

3. **Use Git for version control**
   - Commit frequently
   - Push to GitHub regularly
   - Use branches for features

### Resource Management

1. **Monitor resource usage**
   - Check htop/btop regularly
   - Watch disk space (ncdu)
   - Monitor Docker usage

2. **Clean up regularly**
   - Prune Docker images/containers
   - Remove old build artifacts
   - Archive old projects

3. **Use Docker for isolation**
   - Build in containers
   - Test in containers
   - Deploy from containers

### Security

1. **Keep system updated**
   - Run update-all.sh weekly
   - Monitor security advisories
   - Apply patches promptly

2. **Use strong passwords**
   - Generate random passwords
   - Don't reuse passwords
   - Store in password manager

3. **Backup regularly**
   - Verify backups work
   - Test restore procedure
   - Keep offsite backup (optional)

### Workflow

1. **Use tmux for sessions**
   - Persistent sessions
   - Multiple panes
   - Detach/reattach

2. **Leverage GitHub Copilot**
   - Code suggestions
   - Documentation
   - Test generation

3. **Utilize Google AI**
   - Vertex AI for ML
   - Gemini API for content
   - Helper scripts for testing

---

**Архитектура разработана для максимальной производительности, безопасности и удобства использования одним пользователем с поддержкой множества проектов.**
