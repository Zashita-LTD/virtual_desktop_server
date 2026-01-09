---
alwaysApply: true
always_on: true
trigger: always_on
applyTo: "**"
description: Security Best Practices for Virtual Desktop Server
---

# 🔐 Security Best Practices - Virtual Desktop Server

## Обязательные правила при разработке

### 1. IP Whitelist (Firewall Rules)

**НИКОГДА не используй `0.0.0.0/0` или `::/0` для:**
- SSH (порт 22)
- HTTPS (порт 443)
- code-server (порт 8443)

**Всегда используй IP whitelist из Terraform_VPS_VPN проекта:**

```hcl
# Доверенные IP адреса VPN инфраструктуры
source_ranges = var.ssh_allowed_ips  # или code_server_allowed_ips, https_allowed_ips

# Разрешённые IP:
# DigitalOcean: 146.190.147.78, 165.232.153.33, 165.232.145.104, 134.199.137.209
# Yandex Cloud: 158.160.150.162, 84.252.133.240  
# Hetzner: 185.154.194.145
# Russia: 31.173.84.228
```

**Исключение:** ICMP можно оставить открытым для диагностики.

---

### 2. Пароли и секреты

**НИКОГДА не хардкодь пароли в файлах:**
```yaml
# ❌ НЕПРАВИЛЬНО
password: devpassword
POSTGRES_PASSWORD: mypassword123

# ✅ ПРАВИЛЬНО  
password: ${PASSWORD_FROM_ENV}
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?Set password in .env}
```

**Генерация паролей:**
```bash
# Минимум 32 символа
openssl rand -base64 32
```

**Файлы с паролями должны быть в .gitignore:**
- `.env`
- `*.tfvars` (кроме `.example`)
- `*credentials*`
- `*secret*`

---

### 3. Docker порты

**Все порты баз данных только на localhost:**
```yaml
# ❌ НЕПРАВИЛЬНО
ports:
  - "5432:5432"

# ✅ ПРАВИЛЬНО
ports:
  - "127.0.0.1:5432:5432"
```

**Сервисы, требующие localhost:**
- PostgreSQL (5432)
- Redis (6379)
- MongoDB (27017)
- MySQL (3306)
- Любые БД и внутренние сервисы

---

### 4. SSH ключи

**Используй только ED25519 или RSA-4096:**
```bash
ssh-keygen -t ed25519 -C "email@example.com"
```

**Никогда не коммить приватные ключи:**
- `id_rsa`
- `id_ed25519`
- `*.pem`
- `*.key`

---

### 5. Terraform State

**State файлы содержат секреты - защищай их:**
- Используй remote backend (GCS, S3)
- Включи encryption at rest
- Ограничь доступ к bucket

```hcl
terraform {
  backend "gcs" {
    bucket  = "your-tf-state-bucket"
    prefix  = "virtual-desktop"
    # encryption_key = var.encryption_key  # Опционально
  }
}
```

---

### 6. Service Account

**Минимальные права (Principle of Least Privilege):**
```hcl
# ✅ Только необходимые роли
roles = [
  "roles/aiplatform.user",        # Vertex AI - только использование
  "roles/logging.logWriter",       # Только запись логов
  "roles/monitoring.metricWriter", # Только метрики
  "roles/storage.objectAdmin",     # Только для backup bucket
]

# ❌ Избегай широких ролей
# "roles/owner"
# "roles/editor"  
# "roles/compute.admin"
```

---

### 7. Nginx/SSL

**Обязательные security headers:**
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

**TLS конфигурация:**
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5:!3DES;
ssl_prefer_server_ciphers on;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
```

---

### 8. Fail2ban

**Обязательно настроить для:**
- SSH (sshd)
- code-server
- Nginx (если используется)

```ini
[code-server]
enabled = true
maxretry = 5
bantime = 3600
findtime = 600
```

---

### 9. Логирование

**Логируй security events:**
- Неудачные попытки входа
- Изменения конфигурации
- Доступ к чувствительным данным

**Не логируй:**
- Пароли
- Токены
- Ключи API

---

### 10. Обновления

**Регулярно обновляй:**
```bash
# Система
apt update && apt upgrade -y

# Docker images
docker-compose pull && docker-compose up -d

# code-server
# Проверяй releases на GitHub
```

---

## Чек-лист перед коммитом

- [ ] Нет хардкоженных паролей/токенов
- [ ] Нет открытых портов на 0.0.0.0/0 (кроме ICMP)
- [ ] Все порты БД на 127.0.0.1
- [ ] Secrets в .env файлах (не в коде)
- [ ] .gitignore включает все sensitive файлы
- [ ] Используются переменные для IP whitelist
- [ ] Service account имеет минимальные права

---

## Контакты для security issues

- Email: oncall@zashita.com
- Slack: #security-alerts
