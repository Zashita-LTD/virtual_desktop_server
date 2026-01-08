# Решение проблем (Troubleshooting)

Руководство по диагностике и решению распространенных проблем в Virtual Desktop Server.

## 🔍 Общая диагностика

### Проверка здоровья системы

```bash
# Запустить health check скрипт
sudo bash scripts/management/health-check.sh

# Проверить статус всех критичных сервисов
sudo systemctl status code-server docker fail2ban

# Проверить использование ресурсов
htop
# или
btop

# Проверить диск
df -h

# Проверить логи
journalctl -p err -b  # Все ошибки с последней загрузки
```

## 🖥️ code-server проблемы

### code-server не запускается

**Симптомы:**
- Не можете подключиться через браузер
- `sudo systemctl status code-server` показывает "failed" или "inactive"

**Диагностика:**
```bash
# Проверить статус
sudo systemctl status code-server

# Проверить логи
journalctl -u code-server -n 100 --no-pager

# Проверить конфигурацию
cat ~/.config/code-server/config.yaml

# Проверить процесс
ps aux | grep code-server

# Проверить порт
sudo netstat -tulpn | grep 8443
# или
sudo ss -tulpn | grep 8443
```

**Решения:**

**1. Конфликт портов:**
```bash
# Найти процесс на порту 8443
sudo lsof -i :8443

# Убить процесс (если не code-server)
sudo kill -9 <PID>

# Перезапустить code-server
sudo systemctl restart code-server
```

**2. Проблемы с правами:**
```bash
# Проверить владельца конфигурации
ls -la ~/.config/code-server/

# Исправить права (выполнить от пользователя, не от sudo)
chmod 600 ~/.config/code-server/config.yaml

# Перезапустить
sudo systemctl restart code-server
```

**3. Поврежденная конфигурация:**
```bash
# Создать резервную копию
cp ~/.config/code-server/config.yaml ~/.config/code-server/config.yaml.backup

# Пересоздать базовую конфигурацию
cat > ~/.config/code-server/config.yaml << 'EOF'
bind-addr: 0.0.0.0:8443
auth: password
password: $(openssl rand -base64 24)
cert: true
EOF

# Перезапустить
sudo systemctl restart code-server
```

**4. Проблемы с сертификатом:**
```bash
# Проверить сертификат
ls -la ~/.local/share/code-server/

# Пересоздать самоподписанный сертификат
rm ~/.local/share/code-server/*.{crt,key}

# Перезапустить (сертификат создастся автоматически)
sudo systemctl restart code-server
```

### Не могу подключиться через браузер

**Симптомы:**
- Timeout или "Connection refused" в браузере
- `https://34.46.96.77:8443` недоступен

**Диагностика:**
```bash
# 1. Проверить что code-server запущен
sudo systemctl status code-server

# 2. Проверить firewall
sudo ufw status
sudo iptables -L -n | grep 8443

# 3. Проверить что слушает на правильном интерфейсе
sudo netstat -tulpn | grep 8443

# 4. Тест локально на сервере
curl -k https://localhost:8443
```

**Решения:**

**1. Firewall блокирует:**
```bash
# Проверить UFW
sudo ufw status

# Добавить правило если отсутствует
sudo ufw allow 8443/tcp

# Перезагрузить UFW
sudo ufw reload

# Проверить GCP firewall в консоли
# https://console.cloud.google.com/networking/firewalls
```

**2. code-server слушает на неправильном интерфейсе:**
```bash
# Проверить bind-addr в конфигурации
grep bind-addr ~/.config/code-server/config.yaml

# Должно быть: bind-addr: 0.0.0.0:8443
# Не: bind-addr: 127.0.0.1:8443

# Исправить если неправильно
sed -i 's/bind-addr: 127.0.0.1/bind-addr: 0.0.0.0/' ~/.config/code-server/config.yaml

# Перезапустить
sudo systemctl restart code-server
```

**3. GCP Firewall:**
```bash
# Проверить через gcloud
gcloud compute firewall-rules list --filter="name~'code-server'"

# Создать правило если отсутствует
gcloud compute firewall-rules create allow-code-server \
  --allow=tcp:8443 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow code-server access"
```

### Забыл пароль code-server

**Решение:**
```bash
# Посмотреть текущий пароль
cat ~/.config/code-server/config.yaml | grep password

# Или сгенерировать новый
NEW_PASSWORD=$(openssl rand -base64 24)
echo "New password: $NEW_PASSWORD"

# Обновить конфигурацию
sed -i "s/password: .*/password: $NEW_PASSWORD/" ~/.config/code-server/config.yaml

# Перезапустить
sudo systemctl restart code-server
```

### code-server медленно работает

**Диагностика:**
```bash
# Проверить CPU
top
htop

# Проверить память
free -h

# Проверить диск I/O
iostat -x 1 5

# Проверить network latency (с вашего компьютера)
ping 34.46.96.77
```

**Решения:**

**1. Высокая нагрузка CPU/RAM:**
```bash
# Найти процессы с высокой нагрузкой
top -o %CPU
top -o %MEM

# Убить ресурсоемкие процессы
kill -9 <PID>

# Очистить Docker containers
docker ps -a
docker rm $(docker ps -aq -f status=exited)
```

**2. Много открытых расширений:**
```
В code-server UI:
1. Extensions (Ctrl+Shift+X)
2. Отключить неиспользуемые расширения
3. Reload window (Ctrl+R)
```

**3. Большой workspace:**
```bash
# Проверить размер workspace
du -sh /data/shared/projects/workspace*

# Добавить в .gitignore большие файлы/папки
echo "node_modules/" >> .gitignore
echo "*.log" >> .gitignore
echo "dist/" >> .gitignore
```

**4. Network latency:**
```
Если ping > 200ms, рассмотрите:
- Использование VPN
- Перемещение instance ближе к вашей локации
- Использование tmux для минимизации network round-trips
```

## 🐋 Docker проблемы

### Docker daemon не запущен

**Симптомы:**
- `docker: Cannot connect to the Docker daemon`

**Решение:**
```bash
# Запустить Docker
sudo systemctl start docker

# Включить автозапуск
sudo systemctl enable docker

# Проверить статус
sudo systemctl status docker
```

### Permission denied при запуске Docker

**Симптомы:**
- `permission denied while trying to connect to the Docker daemon socket`

**Решение:**
```bash
# Добавить пользователя в группу docker
sudo usermod -aG docker $USER

# Применить изменения (или перелогиниться)
newgrp docker

# Проверить
docker ps
```

### Недостаточно места для Docker images

**Диагностика:**
```bash
# Проверить использование Docker
docker system df

# Список больших images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k 3 -h
```

**Решение:**
```bash
# Удалить неиспользуемые containers
docker container prune

# Удалить неиспользуемые images
docker image prune -a

# Удалить все (containers, images, volumes, networks)
docker system prune -a --volumes

# Осторожно! Это удалит ВСЁ неиспользуемое
```

### Docker container не запускается

**Диагностика:**
```bash
# Посмотреть логи
docker logs <container-id>

# Попробовать запустить интерактивно
docker run -it <image> /bin/bash
```

## 🔐 Git и GitHub проблемы

### Git authentication failed

**Симптомы:**
- `Authentication failed` при push/pull

**Решения:**

**1. Для HTTPS (с GitHub token):**
```bash
# Создать Personal Access Token в GitHub:
# Settings → Developer settings → Personal access tokens → Generate new token
# Выбрать scopes: repo, workflow

# Настроить Git для хранения credentials
git config --global credential.helper store

# При следующем push введите:
# Username: ваш-github-username
# Password: ваш-token (не пароль!)
```

**2. Для SSH:**
```bash
# Проверить SSH ключи
ls -la ~/.ssh/

# Создать новый ключ если нужно
ssh-keygen -t ed25519 -C "your-email@example.com"

# Скопировать публичный ключ
cat ~/.ssh/id_ed25519.pub

# Добавить в GitHub:
# Settings → SSH and GPG keys → New SSH key

# Тест подключения
ssh -T git@github.com
```

**3. GitHub CLI:**
```bash
# Авторизация через gh
gh auth login

# Выбрать:
# - GitHub.com
# - HTTPS или SSH
# - Login with a web browser
```

### Git push отклонен (rejected)

**Симптомы:**
- `! [rejected] main -> main (non-fast-forward)`

**Решения:**

**1. Обновить локальную копию:**
```bash
# Pull с rebase
git pull --rebase origin main

# Решить конфликты если есть
git status
# Отредактировать файлы с конфликтами
git add .
git rebase --continue

# Push
git push origin main
```

**2. Force push (осторожно!):**
```bash
# Только если уверены что хотите перезаписать remote
git push --force-with-lease origin main
```

### GitHub Copilot не работает

**Симптомы:**
- Нет suggestions
- "Copilot is not available"

**Диагностика:**
```bash
# Проверить статус Copilot
# В code-server: Ctrl+Shift+P → "Copilot: Check Status"
```

**Решения:**

**1. Не авторизован:**
```
1. В code-server UI
2. Extensions → GitHub Copilot → Sign in
3. Следовать инструкциям
```

**2. Нет активной подписки:**
```
1. Проверить в GitHub: https://github.com/settings/copilot
2. Подписаться на GitHub Copilot
3. Или использовать студенческий/учительский план
```

**3. Расширение не установлено:**
```bash
# Установить через CLI
code-server --install-extension github.copilot

# Или через UI: Extensions → Search "GitHub Copilot" → Install
```

## ☁️ Google Cloud AI проблемы

### Vertex AI authentication errors

**Симптомы:**
- `PermissionDenied: 403`
- `Unauthenticated: 401`

**Решения:**

**1. Проверить Application Default Credentials:**
```bash
# Показать текущий аккаунт
gcloud auth list

# Показать токен (должен быть валидным)
gcloud auth application-default print-access-token

# Переавторизоваться
gcloud auth application-default login
```

**2. Проверить Service Account (если используется):**
```bash
# Проверить переменную окружения
echo $GOOGLE_APPLICATION_CREDENTIALS

# Проверить файл существует и валидный
cat $GOOGLE_APPLICATION_CREDENTIALS | jq .

# Активировать service account
gcloud auth activate-service-account \
  --key-file=$GOOGLE_APPLICATION_CREDENTIALS
```

**3. Проверить IAM permissions:**
```bash
# В GCP Console:
# IAM & Admin → IAM
# Найти свой service account или user
# Должен иметь роли:
# - Vertex AI User
# - AI Platform Developer (или Editor/Owner)

# Или через CLI
gcloud projects get-iam-policy viktor-integration \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:YOUR_SA_EMAIL"
```

### API not enabled

**Симптомы:**
- `API [aiplatform.googleapis.com] not enabled on project`

**Решение:**
```bash
# Включить необходимые APIs
gcloud services enable aiplatform.googleapis.com
gcloud services enable generativelanguage.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable language.googleapis.com

# Проверить включенные APIs
gcloud services list --enabled | grep -i ai
```

### Quota exceeded

**Симптомы:**
- `Quota exceeded for quota metric 'Predictions per minute'`

**Решения:**

**1. Проверить текущее использование:**
```
GCP Console → IAM & Admin → Quotas
Filter by: "Vertex AI"
```

**2. Запросить увеличение:**
```
1. Выбрать нужную квоту
2. EDIT QUOTAS
3. Указать новый лимит
4. Submit Request
```

**3. Добавить retry в код:**
```python
import time
from google.api_core import exceptions

def predict_with_retry(endpoint, instances, max_retries=5):
    for attempt in range(max_retries):
        try:
            return endpoint.predict(instances=instances)
        except exceptions.ResourceExhausted as e:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Quota exceeded, waiting {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise
```

### Gemini API "API key not valid"

**Решение:**
```bash
# Проверить API key установлен
echo $GOOGLE_API_KEY

# Если пустой, установить
export GOOGLE_API_KEY="your-api-key"

# Добавить в .bashrc для persistence
echo 'export GOOGLE_API_KEY="your-api-key"' >> ~/.bashrc

# Проверить key валидный в Google AI Studio:
# https://makersuite.google.com/app/apikey
```

## 💾 Backup и Storage проблемы

### Backup не создается автоматически

**Диагностика:**
```bash
# Проверить статус timer
sudo systemctl status backup.timer

# Проверить когда последний раз запускался
sudo journalctl -u backup.service -n 50

# Проверить schedule
sudo systemctl list-timers | grep backup
```

**Решение:**
```bash
# Включить timer если отключен
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Проверить конфигурацию timer
cat /etc/systemd/system/backup.timer

# Ручной запуск для теста
sudo systemctl start backup.service
```

### Недостаточно места на диске

**Диагностика:**
```bash
# Общая информация
df -h

# Детальный анализ
ncdu /

# Топ-10 больших директорий
du -h / 2>/dev/null | sort -rh | head -10

# Проверить inodes (иногда закончиваются раньше места)
df -i
```

**Решения:**

**1. Очистить Docker:**
```bash
# Удалить все неиспользуемое
docker system prune -a --volumes

# Освободит несколько GB обычно
```

**2. Очистить логи:**
```bash
# Проверить размер логов
sudo du -sh /var/log/

# Очистить старые логи
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=1G

# Очистить apt cache
sudo apt clean
sudo apt autoclean
```

**3. Удалить старые бэкапы:**
```bash
# Список бэкапов
ls -lh /backup/

# Удалить старше 7 дней
find /backup/ -name "projects_*.tar.gz" -mtime +7 -delete
```

**4. Очистить build artifacts:**
```bash
# Node.js
find /data/shared/projects -name "node_modules" -type d -prune -exec rm -rf {} \;

# Python
find /data/shared/projects -name "__pycache__" -type d -prune -exec rm -rf {} \;
find /data/shared/projects -name "*.pyc" -delete

# Временные файлы
find /tmp -type f -atime +7 -delete
```

### Restore из backup не работает

**Диагностика:**
```bash
# Проверить архив не поврежден
tar -tzf /backup/projects_YYYYMMDD_HHMMSS.tar.gz | head

# Проверить есть ли место для restore
df -h /data/shared/projects
```

**Решение:**
```bash
# Ручной restore
sudo systemctl stop code-server

# Создать резервную копию текущих файлов
sudo mv /data/shared/projects /data/shared/projects.old

# Создать директорию
sudo mkdir -p /data/shared/projects

# Распаковать
sudo tar -xzf /backup/projects_YYYYMMDD_HHMMSS.tar.gz -C /data/shared/

# Исправить права
sudo chown -R vik9541:vik9541 /data/shared/projects

# Запустить code-server
sudo systemctl start code-server
```

## 🔒 Security проблемы

### fail2ban не работает

**Диагностика:**
```bash
# Статус
sudo systemctl status fail2ban

# Проверить логи
sudo journalctl -u fail2ban -n 100

# Проверить jails
sudo fail2ban-client status

# Проверить конкретный jail
sudo fail2ban-client status code-server
```

**Решение:**
```bash
# Перезапустить
sudo systemctl restart fail2ban

# Проверить конфигурацию
sudo fail2ban-client -d

# Если ошибки в конфигурации, исправить
sudo nano /etc/fail2ban/jail.d/code-server.conf
```

### UFW firewall заблокировал меня

**Симптомы:**
- Не могу подключиться по SSH
- (Требуется доступ через GCP Console)

**Решение:**
```bash
# Через GCP Console Serial Console:

# Отключить UFW
sudo ufw disable

# Или сбросить правила
sudo ufw --force reset

# Настроить правильно
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8443/tcp
sudo ufw enable
```

### SSL сертификат истек

**Симптомы:**
- Браузер показывает "Your connection is not private"
- Сертификат expired

**Решение для самоподписанных:**
```bash
# Удалить старый сертификат
rm ~/.local/share/code-server/*.{crt,key}

# Перезапустить (создаст новый)
sudo systemctl restart code-server
```

**Решение для Let's Encrypt:**
```bash
# Обновить сертификат
sudo certbot renew

# Перезапустить nginx (если используется)
sudo systemctl restart nginx

# Или code-server
sudo systemctl restart code-server
```

## 🌐 Network проблемы

### Медленное соединение

**Диагностика:**
```bash
# С вашего компьютера:
ping 34.46.96.77
traceroute 34.46.96.77

# На сервере:
speedtest-cli  # Установить если нужно: sudo apt install speedtest-cli
```

**Решения:**
- Использовать tmux для минимизации network latency
- Рассмотреть VPN если ISP throttling
- Перенести instance в region ближе к вам

### Не могу получить внешний IP

**Диагностика:**
```bash
# На сервере
curl ifconfig.me

# Через gcloud
gcloud compute instances describe instance-20260108-153942 \
  --zone=us-central1-c \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## 📞 Когда обращаться за помощью

Если вы выполнили все шаги troubleshooting и проблема остается:

1. **Соберите информацию:**
```bash
# Запустить health check
sudo bash scripts/management/health-check.sh > health-report.txt

# Собрать логи
sudo journalctl -b > system-logs.txt
sudo journalctl -u code-server -n 500 > code-server-logs.txt

# Системная информация
uname -a > system-info.txt
df -h >> system-info.txt
free -h >> system-info.txt
```

2. **Опишите проблему:**
   - Что вы пытались сделать
   - Что произошло вместо ожидаемого
   - Какие troubleshooting шаги выполнили
   - Логи и error messages

3. **Контакты:**
   - GitHub Issues: репозиторий проекта
   - Internal support (для Zashita LTD)

## 📚 Полезные команды для диагностики

**Системная информация:**
```bash
uname -a                    # Kernel version
lsb_release -a             # Ubuntu version
uptime                     # System uptime
free -h                    # Memory usage
df -h                      # Disk usage
ncdu /                     # Interactive disk usage
```

**Сервисы:**
```bash
systemctl list-units --type=service --state=running  # Running services
systemctl list-units --type=service --state=failed   # Failed services
journalctl -p err -b       # All errors since boot
```

**Network:**
```bash
ip addr                    # Network interfaces
ss -tulpn                  # Listening ports
sudo netstat -tulpn        # Listening ports (alternative)
ping -c 4 8.8.8.8         # Internet connectivity
dig google.com            # DNS resolution
```

**Processes:**
```bash
top                        # Process monitor
htop                       # Better process monitor
ps aux | grep <process>    # Find process
pgrep -a <name>           # Find process by name
```

---

**При возникновении проблем - не паникуйте! Следуйте этому guide шаг за шагом. 🔧**
