# Virtual Desktop Server

Централизованная среда разработки на базе GCP для пользователя vik9541 с поддержкой множества проектов через 5 специализированных workspaces.

## 🎯 Обзор проекта

Этот проект предоставляет полностью настроенную среду разработки на GCP instance с code-server (VS Code в браузере), поддержкой множества языков программирования и интеграцией с Google Cloud AI.

```
┌─────────────────────────────────────────────────────────────┐
│                   GCP Instance (e2-highmem-8)                │
│                    8 vCPU, 64 GB RAM, 500 GB SSD             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────────────────────────────┐ │
│  │              │  │     code-server (VS Code)             │ │
│  │   User       │──│  https://34.46.96.77:8443             │ │
│  │  (vik9541)   │  │                                        │ │
│  │              │  │  ┌─────────────────────────────────┐  │ │
│  └──────────────┘  │  │  5 Workspaces:                   │ │
│                    │  │  • Frontend (React, Vue, etc)    │  │
│                    │  │  • Backend (Node, Python, Go)    │  │
│                    │  │  • AI/ML (TensorFlow, PyTorch)   │  │
│                    │  │  • Infrastructure (Terraform, K8s│  │
│                    │  │  • Experiments (Prototyping)     │  │
│                    │  └─────────────────────────────────┘  │ │
│                    └──────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Dev Tools: Git, Docker, Node.js, Python, Go, Rust      ││
│  │  Cloud: Google Cloud SDK, Vertex AI, Gemini API         ││
│  │  Security: UFW, fail2ban, SSL/TLS                       ││
│  │  Monitoring: Cloud Ops Agent, Logs, Metrics             ││
│  │  Backup: Автоматические бэкапы (systemd timer)          ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

```bash
# 1. Клонировать репозиторий
git clone https://github.com/Zashita-LTD/virtual_desktop_server.git
cd virtual_desktop_server

# 2. Настроить переменные окружения
cp .env.example .env
nano .env  # Отредактируйте необходимые параметры

# 3. Запустить установку (требуется sudo)
sudo bash scripts/install/00-master-install.sh

# 4. Открыть code-server в браузере
# https://34.46.96.77:8443
# Пароль сохранен в ~/.config/code-server/config.yaml
```

## 📋 Спецификация сервера

- **Instance:** instance-20260108-153942
- **Машина:** e2-highmem-8 (8 vCPU, 64 GB RAM)
- **ОС:** Ubuntu 24.04 LTS (Noble)
- **Диск:** 500 GB SSD
- **Локация:** us-central1-c
- **External IP:** 34.46.96.77
- **Service Account:** 763289222664-compute@developer.gserviceaccount.com

## 📚 Документация

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Пошаговая инструкция по развертыванию
- **[docs/architecture.md](docs/architecture.md)** - Архитектура системы
- **[docs/user-guide.md](docs/user-guide.md)** - Руководство пользователя
- **[docs/workspaces-guide.md](docs/workspaces-guide.md)** - Работа с workspaces
- **[docs/google-ai-integration.md](docs/google-ai-integration.md)** - Интеграция с Google AI
- **[docs/troubleshooting.md](docs/troubleshooting.md)** - Решение проблем

## ✨ Возможности

### 🖥️ Code-server (VS Code в браузере)
- Доступ к полнофункциональному VS Code через HTTPS
- 5 предконфигурированных workspaces для разных типов проектов
- Поддержка GitHub Copilot
- Автозапуск через systemd

### 🛠️ Инструменты разработки
- **Languages:** Node.js v20, Python 3.12+, Go 1.21+, Rust
- **Containers:** Docker 24.x, Docker Compose v2
- **Version Control:** Git, GitHub CLI (gh)
- **Build Tools:** gcc, g++, make, cmake
- **Utilities:** tmux, htop, btop, jq, tree, ncdu

### ☁️ Google Cloud AI
- Google Cloud SDK (gcloud CLI)
- Vertex AI SDK (Python, Node.js)
- Gemini API интеграция
- Готовые примеры и helper скрипты

### 🔒 Безопасность
- UFW firewall (только порты 22, 443, 8443)
- SSL/TLS сертификаты (самоподписанные + Let's Encrypt инструкции)
- fail2ban защита от brute-force атак
- Автоматические обновления безопасности

### 📊 Мониторинг и бэкапы
- Google Cloud Ops Agent для метрик и логов
- Автоматические ежедневные бэкапы (systemd timer)
- Health check скрипты
- Ротация бэкапов (7 дней)

## 🗂️ Структура проекта

```
/
├── README.md                    # Этот файл
├── DEPLOYMENT.md                # Инструкция по развертыванию
├── docs/                        # Документация
├── scripts/
│   ├── install/                 # Скрипты установки
│   ├── management/              # Управление системой
│   ├── workspaces/              # Управление workspace'ами
│   └── ai-helpers/              # Вспомогательные AI скрипты
├── config/                      # Конфигурационные файлы
│   ├── code-server/
│   ├── nginx/
│   ├── workspaces/              # 5 .code-workspace файлов
│   ├── tmux/
│   ├── systemd/
│   └── fail2ban/
├── terraform/                   # Infrastructure as Code
├── docker/                      # Docker конфигурации
└── .github/workflows/           # CI/CD (опционально)
```

## 🎯 Workspaces

### 1. Frontend (workspace1-frontend)
- React, Vue.js, Angular проекты
- HTML/CSS/JavaScript разработка
- Рекомендуемые расширения: ESLint, Prettier, Live Server

### 2. Backend (workspace2-backend)
- Node.js, Python, Go серверы
- REST API, GraphQL
- Рекомендуемые расширения: Python, Go, REST Client

### 3. AI/ML (workspace3-ai-ml)
- TensorFlow, PyTorch проекты
- Jupyter notebooks
- Vertex AI, Gemini API интеграция
- Рекомендуемые расширения: Jupyter, Python, Data Science

### 4. Infrastructure (workspace4-infrastructure)
- Terraform, Kubernetes конфигурации
- DevOps скрипты
- Рекомендуемые расширения: Terraform, Kubernetes, YAML

### 5. Experiments (workspace5-experiments)
- Прототипирование
- Обучение новым технологиям
- Временные проекты

## 📦 Требования к системе

- Ubuntu 24.04 LTS
- Минимум 8 GB RAM (рекомендуется 64 GB)
- Минимум 100 GB дискового пространства (рекомендуется 500 GB)
- Sudo доступ
- Интернет соединение

## 🔧 Управление

```bash
# Проверка здоровья системы
sudo bash scripts/management/health-check.sh

# Создание бэкапа
sudo bash scripts/management/backup.sh

# Восстановление из бэкапа
sudo bash scripts/management/restore.sh

# Обновление всех компонентов
sudo bash scripts/management/update-all.sh

# Создание нового workspace
bash scripts/workspaces/create-workspace.sh workspace-name
```

## 📈 Статус проекта

### ✅ Завершено
- ✅ Структура проекта создана
- ✅ Документация написана (10 файлов)
- ✅ Скрипты установки готовы (7 скриптов)
- ✅ Конфигурационные файлы подготовлены
- ✅ Terraform конфигурация готова
- ✅ Docker Compose настроен
- ✅ GitHub Actions workflow создан

### 🔐 Безопасность (Январь 2026)
- ✅ IP Whitelist для всех firewall правил (21 VPN IP)
- ✅ Все порты БД на localhost (127.0.0.1)
- ✅ Пароли через .env файлы (не хардкод)
- ✅ Security-setup.sh скрипт автогенерации паролей
- ✅ Fail2ban для code-server
- ✅ UFW firewall конфигурация
- ✅ Security headers в Nginx
- ✅ .gitignore для всех sensitive файлов
- ✅ Инструкции безопасности (.github/instructions/)

### 🔄 В процессе
- 🔄 Тестирование на GCP instance
- 🔄 Let's Encrypt сертификаты (опционально)

### 📋 TODO (следующие шаги)
1. Развернуть на GCP с помощью Terraform
2. Настроить мониторинг (Prometheus/Grafana)
3. Настроить автоматические бэкапы
4. Добавить 2FA для code-server
5. Настроить VPN подключение к серверу

## 🤝 Поддержка

При возникновении проблем:
1. Проверьте [docs/troubleshooting.md](docs/troubleshooting.md)
2. Запустите `scripts/management/health-check.sh`
3. Проверьте логи: `journalctl -u code-server -n 100`

## 📝 Лицензия

Проприетарный проект для Zashita LTD.

## 👤 Автор

Разработано для пользователя vik9541 и команды Zashita LTD.
