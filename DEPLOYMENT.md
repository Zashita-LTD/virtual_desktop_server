# Развертывание Virtual Desktop Server

Пошаговая инструкция по развертыванию централизованной среды разработки на GCP instance.

## 📋 Предварительные требования

### Системные требования
- **ОС:** Ubuntu 24.04 LTS (Noble)
- **CPU:** Минимум 4 vCPU (рекомендуется 8)
- **RAM:** Минимум 8 GB (рекомендуется 64 GB)
- **Диск:** Минимум 100 GB (рекомендуется 500 GB SSD)
- **Доступ:** Sudo права

### Необходимые доступы
- SSH доступ к серверу
- Интернет соединение на сервере
- (Опционально) GitHub аккаунт для Copilot
- (Опционально) Google Cloud credentials для AI интеграции

## 🚀 Быстрое развертывание

### Шаг 1: Подключение к серверу

```bash
# Подключение через SSH
ssh vik9541@34.46.96.77

# Или через gcloud
gcloud compute ssh instance-20260108-153942 \
  --zone=us-central1-c \
  --project=viktor-integration
```

### Шаг 2: Клонирование репозитория

```bash
# Установить git если не установлен
sudo apt update
sudo apt install -y git

# Клонировать репозиторий
cd ~
git clone https://github.com/Zashita-LTD/virtual_desktop_server.git
cd virtual_desktop_server
```

### Шаг 3: Настройка переменных окружения

```bash
# Скопировать пример конфигурации
cp .env.example .env

# Отредактировать файл .env
nano .env
```

Минимальная конфигурация в `.env`:
```bash
SERVER_IP=34.46.96.77
GCP_PROJECT_ID=viktor-integration
GCP_REGION=us-central1
GCP_ZONE=us-central1-c
BACKUP_DIR=/backup
BACKUP_RETENTION_DAYS=7
```

### Шаг 4: Запуск master-установки

```bash
# Сделать скрипты исполняемыми
chmod +x scripts/install/*.sh
chmod +x scripts/management/*.sh
chmod +x scripts/workspaces/*.sh

# Запустить master-установку (занимает 15-30 минут)
sudo bash scripts/install/00-master-install.sh
```

### Шаг 5: Получение пароля для code-server

```bash
# Пароль сохранен в конфигурационном файле
cat ~/.config/code-server/config.yaml | grep password
```

### Шаг 6: Открытие code-server

1. Откройте браузер
2. Перейдите по адресу: `https://34.46.96.77:8443`
3. Примите самоподписанный сертификат (или настройте Let's Encrypt)
4. Введите пароль из предыдущего шага

**Готово! 🎉** Ваша среда разработки запущена!

---

## 🔧 Детальная установка (пошагово)

Если вы хотите выполнить установку по шагам вместо использования master-скрипта:

### 1. Подготовка системы

```bash
sudo bash scripts/install/01-system-prep.sh
```

**Что происходит:**
- Обновление всех пакетов системы
- Установка базовых зависимостей (curl, wget, build-essential)
- Настройка временной зоны
- Установка unattended-upgrades для автообновлений

**Время выполнения:** ~5 минут

### 2. Настройка хранилища

```bash
sudo bash scripts/install/02-storage-setup.sh
```

**Что происходит:**
- Создание директории `/data/shared/projects`
- Настройка прав доступа
- Создание структуры для 5 workspaces
- Создание README.md в каждом workspace

**Время выполнения:** <1 минута

### 3. Установка code-server

```bash
sudo bash scripts/install/03-code-server-install.sh
```

**Что происходит:**
- Загрузка и установка code-server последней версии
- Генерация конфигурации (config.yaml)
- Создание самоподписанного SSL сертификата
- Настройка systemd service для автозапуска
- Установка базовых расширений VS Code

**Время выполнения:** ~3 минуты

### 4. Установка инструментов разработки

```bash
sudo bash scripts/install/04-dev-tools.sh
```

**Что происходит:**
- Git + GitHub CLI (gh)
- Docker 24.x + Docker Compose v2
- Node.js v20 LTS + npm + yarn + pnpm
- Python 3.12+ + pip + venv + poetry
- Go 1.21+
- Rust (cargo)
- tmux, screen, htop, btop
- jq, tree, ncdu

**Время выполнения:** ~10 минут

### 5. Установка Google Cloud SDK

```bash
sudo bash scripts/install/05-google-cloud-sdk.sh
```

**Что происходит:**
- Установка gcloud CLI
- Установка Python библиотек (google-cloud-aiplatform, vertexai)
- Установка Node.js библиотек (@google-cloud/aiplatform)
- Создание helper скриптов для тестирования

**Время выполнения:** ~3 минуты

### 6. Настройка безопасности

```bash
sudo bash scripts/install/06-security-setup.sh
```

**Что происходит:**
- Настройка UFW firewall (порты 22, 443, 8443)
- Установка и настройка fail2ban
- Генерация SSL сертификатов
- (Опционально) Настройка Nginx reverse proxy

**Время выполнения:** ~2 минуты

### 7. Настройка мониторинга

```bash
sudo bash scripts/install/07-monitoring-setup.sh
```

**Что происходит:**
- Установка Google Cloud Ops Agent
- Настройка сбора метрик (CPU, RAM, Disk, Network)
- Настройка сбора логов (syslog, code-server)
- Создание systemd timer для автоматических бэкапов

**Время выполнения:** ~2 минуты

---

## 🔍 Проверка установки

### Проверка статуса сервисов

```bash
# Проверить code-server
sudo systemctl status code-server

# Проверить Docker
sudo systemctl status docker

# Проверить fail2ban
sudo systemctl status fail2ban

# Проверить все важные сервисы
bash scripts/management/health-check.sh
```

### Проверка установленных инструментов

```bash
# Версии инструментов
git --version
docker --version
node --version
python3 --version
go version
cargo --version
gcloud --version

# GitHub CLI
gh --version

# Проверить расширения code-server
code-server --list-extensions
```

### Проверка firewall

```bash
# Статус UFW
sudo ufw status verbose

# Открытые порты должны быть: 22, 443, 8443
```

### Проверка workspaces

```bash
# Список workspaces
ls -la /data/shared/projects/

# Проверить workspace файлы
ls -la config/workspaces/
```

---

## 🎨 Первоначальная настройка code-server

### 1. Первый вход

1. Откройте `https://34.46.96.77:8443`
2. Введите пароль
3. Примите предупреждение о самоподписанном сертификате

### 2. Открытие workspace

**Через UI:**
- File → Open Workspace from File
- Выберите один из файлов в `/data/shared/projects/` или используйте конфигурации из `config/workspaces/`

**Через командную строку:**
```bash
code-server --open /home/runner/work/virtual_desktop_server/virtual_desktop_server/config/workspaces/workspace1-frontend.code-workspace
```

### 3. Установка GitHub Copilot

1. В code-server откройте Extensions (Ctrl+Shift+X)
2. Найдите "GitHub Copilot"
3. Нажмите Install
4. Авторизуйтесь с вашим GitHub аккаунтом

Или через CLI:
```bash
code-server --install-extension github.copilot
```

### 4. Настройка Git

```bash
# Запустить helper скрипт
bash scripts/workspaces/setup-git-config.sh

# Или вручную
git config --global user.name "vik9541"
git config --global user.email "your-email@example.com"

# Настроить GitHub CLI
gh auth login
```

---

## 🔐 Настройка Google Cloud AI (опционально)

### Вариант 1: Service Account (рекомендуется для production)

```bash
# 1. Создать service account в GCP Console
# 2. Загрузить JSON ключ
# 3. Сохранить на сервере

mkdir -p ~/.config/gcloud
mv ~/Downloads/service-account-key.json ~/.config/gcloud/

# 4. Активировать service account
gcloud auth activate-service-account \
  --key-file=~/.config/gcloud/service-account-key.json

# 5. Установить проект по умолчанию
gcloud config set project viktor-integration
```

### Вариант 2: User Account (для разработки)

```bash
# Авторизация через браузер
gcloud auth login

# Установить проект
gcloud config set project viktor-integration

# Настроить Application Default Credentials
gcloud auth application-default login
```

### Тестирование интеграции

```bash
# Тест Vertex AI
python3 scripts/ai-helpers/test-vertex-ai.py

# Тест Gemini API (требуется API ключ)
export GOOGLE_API_KEY="your-api-key"
python3 scripts/ai-helpers/test-gemini.py
```

---

## 🔒 Настройка HTTPS с Let's Encrypt (опционально)

Если у вас есть домен:

### 1. Настроить DNS

```
A record: yourdev.example.com → 34.46.96.77
```

### 2. Установить Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx

# Получить сертификат
sudo certbot --nginx -d yourdev.example.com
```

### 3. Обновить код-сервер для использования Let's Encrypt

```bash
# Отредактировать config.yaml
sudo nano ~/.config/code-server/config.yaml

# Изменить:
# cert: /etc/letsencrypt/live/yourdev.example.com/fullchain.pem
# cert-key: /etc/letsencrypt/live/yourdev.example.com/privkey.pem

# Перезапустить code-server
sudo systemctl restart code-server
```

---

## 🔄 Автоматические бэкапы

Бэкапы настроены автоматически через systemd timer:

```bash
# Проверить статус таймера
sudo systemctl status backup.timer

# Список бэкапов
ls -lh /backup/

# Ручной запуск бэкапа
sudo bash scripts/management/backup.sh

# Восстановление из бэкапа
sudo bash scripts/management/restore.sh /backup/projects_20260108_120000.tar.gz
```

---

## 📊 Мониторинг

### Cloud Monitoring (GCP Console)

1. Откройте [GCP Console](https://console.cloud.google.com)
2. Перейдите в Monitoring → Dashboards
3. Создайте новый dashboard для instance-20260108-153942

### Локальный мониторинг

```bash
# Мониторинг ресурсов в реальном времени
htop

# Или используйте btop (более современный)
btop

# Использование диска
ncdu /

# Статистика Docker
docker stats

# Логи code-server
journalctl -u code-server -f
```

---

## 🆘 Troubleshooting

### code-server не запускается

```bash
# Проверить статус
sudo systemctl status code-server

# Проверить логи
journalctl -u code-server -n 50

# Перезапустить
sudo systemctl restart code-server
```

### Не могу подключиться через браузер

```bash
# Проверить firewall
sudo ufw status

# Проверить что code-server слушает на правильном порту
sudo netstat -tulpn | grep 8443

# Проверить что процесс запущен
ps aux | grep code-server
```

### Нет места на диске

```bash
# Проверить использование
df -h

# Найти большие файлы
ncdu /

# Очистить Docker
docker system prune -a

# Удалить старые бэкапы вручную
sudo rm /backup/projects_*.tar.gz
```

Для других проблем смотрите [docs/troubleshooting.md](docs/troubleshooting.md).

---

## 🔧 Управление после установки

### Обновление системы

```bash
# Обновить все компоненты
sudo bash scripts/management/update-all.sh
```

### Создание нового workspace

```bash
# Создать workspace для нового типа проектов
bash scripts/workspaces/create-workspace.sh workspace6-mobile
```

### Добавление проекта в существующий workspace

```bash
# 1. Клонировать проект
cd /data/shared/projects/workspace1-frontend
git clone https://github.com/your-org/your-project.git

# 2. Открыть workspace в code-server
# 3. File → Add Folder to Workspace
# 4. Выбрать папку проекта
# 5. File → Save Workspace As
```

---

## 📚 Дополнительная информация

- [Архитектура системы](docs/architecture.md)
- [Руководство пользователя](docs/user-guide.md)
- [Работа с workspaces](docs/workspaces-guide.md)
- [Google AI интеграция](docs/google-ai-integration.md)
- [Troubleshooting](docs/troubleshooting.md)

---

## ✅ Чеклист успешной установки

После завершения установки проверьте:

- [ ] code-server доступен по HTTPS на порту 8443
- [ ] Вход с паролем работает
- [ ] 5 workspace файлов созданы
- [ ] Docker установлен и работает
- [ ] Node.js, Python, Go установлены
- [ ] Google Cloud SDK установлен
- [ ] UFW firewall активен (только порты 22, 443, 8443)
- [ ] fail2ban работает
- [ ] Автоматические бэкапы настроены (systemd timer активен)
- [ ] Мониторинг работает (Cloud Ops Agent запущен)
- [ ] Git настроен с вашим именем и email
- [ ] GitHub CLI авторизован (опционально)
- [ ] GitHub Copilot установлен (опционально)

---

**Поздравляем! Ваша среда разработки готова к работе! 🎉**
