# Руководство пользователя

Полное руководство по использованию Virtual Desktop Server для разработки.

## 🚀 Начало работы

### Доступ к среде разработки

1. Откройте браузер (рекомендуется Chrome/Firefox/Edge)
2. Перейдите по адресу: `https://34.46.96.77:8443`
3. Если видите предупреждение о сертификате, нажмите "Advanced" → "Proceed" (для самоподписанного сертификата)
4. Введите пароль из файла `~/.config/code-server/config.yaml`

**Получение пароля:**
```bash
# На сервере
cat ~/.config/code-server/config.yaml | grep password
```

### Первый вход

После успешной авторизации вы увидите VS Code в браузере. Интерфейс идентичен desktop версии VS Code.

**Рекомендуемые первые шаги:**
1. Откройте терминал (Ctrl+` или Terminal → New Terminal)
2. Проверьте установленные инструменты
3. Откройте один из workspaces
4. Настройте Git
5. Установите дополнительные расширения

## 📂 Работа с Workspaces

### Открытие workspace

**Способ 1: Через меню**
1. File → Open Workspace from File...
2. Выберите файл из `/data/shared/projects/config/workspaces/`
3. Например: `workspace1-frontend.code-workspace`

**Способ 2: Через терминал**
```bash
# Открыть workspace напрямую
code /data/shared/projects/workspace1-frontend
```

**Способ 3: Через Welcome Screen**
1. Нажмите на иконку VS Code в левом верхнем углу
2. В разделе "Recent" выберите ранее открытый workspace

### Доступные workspaces

#### 1. Frontend Development (workspace1-frontend)
**Для:**
- React, Vue.js, Angular проекты
- HTML/CSS/JavaScript
- Static websites
- SPAs (Single Page Applications)

**Предустановленные расширения:**
- ESLint
- Prettier
- Live Server
- Auto Rename Tag
- CSS Peek

#### 2. Backend Development (workspace2-backend)
**Для:**
- Node.js серверы (Express, Fastify, NestJS)
- Python веб-приложения (Django, Flask, FastAPI)
- Go серверы
- REST APIs, GraphQL APIs

**Предустановленные расширения:**
- Python
- Go
- REST Client
- Thunder Client
- Database clients

#### 3. AI/ML Development (workspace3-ai-ml)
**Для:**
- Machine Learning проекты
- Data Science
- Jupyter notebooks
- TensorFlow, PyTorch
- Vertex AI интеграция

**Предустановленные расширения:**
- Jupyter
- Python
- Pylance
- Data Wrangler

#### 4. Infrastructure (workspace4-infrastructure)
**Для:**
- Terraform конфигурации
- Kubernetes manifests
- Docker configurations
- CI/CD pipelines
- Ansible playbooks

**Предустановленные расширения:**
- Terraform
- Kubernetes
- Docker
- YAML
- HashiCorp HCL

#### 5. Experiments (workspace5-experiments)
**Для:**
- Прототипирование
- Изучение новых технологий
- Временные проекты
- Proof of concepts

**Предустановленные расширения:**
- General purpose набор

### Добавление проекта в workspace

**Метод 1: Клонировать в workspace директорию**
```bash
# Перейти в директорию workspace
cd /data/shared/projects/workspace1-frontend

# Клонировать проект
git clone https://github.com/your-org/your-project.git

# Проект автоматически появится в workspace
```

**Метод 2: Добавить папку в существующий workspace**
1. File → Add Folder to Workspace...
2. Выберите папку с проектом
3. File → Save Workspace As... (если хотите сохранить изменения)

## 🔧 Инструменты разработки

### Git и GitHub

**Первоначальная настройка:**
```bash
# Настроить имя и email
git config --global user.name "vik9541"
git config --global user.email "your-email@example.com"

# Проверить конфигурацию
git config --list
```

**GitHub CLI:**
```bash
# Авторизация
gh auth login

# Клонировать репозиторий
gh repo clone your-org/your-repo

# Создать PR
gh pr create --title "Feature: ..." --body "..."

# Просмотр issues
gh issue list
```

**Git в VS Code:**
- Source Control панель (Ctrl+Shift+G)
- GitLens для истории
- Git Graph для визуализации
- Inline blame и diff

### Node.js разработка

**Доступные пакетные менеджеры:**
```bash
# npm (default)
npm install
npm run dev

# yarn
yarn install
yarn dev

# pnpm (более быстрый)
pnpm install
pnpm dev
```

**Создание нового Node.js проекта:**
```bash
cd /data/shared/projects/workspace2-backend
mkdir my-node-app && cd my-node-app

# Инициализация
npm init -y

# Установка зависимостей
npm install express

# Создание index.js
cat > index.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF

# Запуск
node index.js
```

### Python разработка

**Virtual environments:**
```bash
# Создать venv
python3 -m venv venv

# Активировать
source venv/bin/activate

# Установить зависимости
pip install -r requirements.txt

# Деактивировать
deactivate
```

**Poetry (рекомендуется):**
```bash
# Инициализация нового проекта
poetry new my-python-project
cd my-python-project

# Установка зависимостей
poetry add requests pandas

# Запуск в poetry environment
poetry run python main.py

# Shell в poetry environment
poetry shell
```

**Jupyter notebooks:**
```bash
# Установка
pip install jupyter

# Запуск (доступ через port forwarding)
jupyter notebook --no-browser --port=8888

# Или использовать встроенную поддержку в VS Code
# Создать файл .ipynb и открыть в VS Code
```

### Go разработка

**Создание Go модуля:**
```bash
cd /data/shared/projects/workspace2-backend
mkdir my-go-app && cd my-go-app

# Инициализация модуля
go mod init github.com/your-org/my-go-app

# Создание main.go
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF

# Запуск
go run main.go

# Сборка
go build
```

### Docker разработка

**Основные команды:**
```bash
# Запуск контейнера
docker run -it ubuntu bash

# Список запущенных контейнеров
docker ps

# Список всех контейнеров
docker ps -a

# Остановить контейнер
docker stop <container-id>

# Удалить контейнер
docker rm <container-id>

# Список образов
docker images

# Удалить образ
docker rmi <image-id>

# Очистка всего
docker system prune -a
```

**Docker Compose:**
```bash
# В директории с docker-compose.yml
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down
```

### tmux (Terminal Multiplexer)

**Основные команды:**
```bash
# Создать новую сессию
tmux new -s mysession

# Список сессий
tmux ls

# Подключиться к сессии
tmux attach -t mysession

# Отключиться от сессии (не закрывая её)
# Нажать: Ctrl+b, затем d
```

**Полезные горячие клавиши:**
- `Ctrl+b %` - разделить панель вертикально
- `Ctrl+b "` - разделить панель горизонтально
- `Ctrl+b arrow` - переключение между панелями
- `Ctrl+b c` - создать новое окно
- `Ctrl+b n` - следующее окно
- `Ctrl+b p` - предыдущее окно
- `Ctrl+b d` - отключиться от сессии

## 🤖 GitHub Copilot

### Установка и активация

**Через VS Code UI:**
1. Extensions (Ctrl+Shift+X)
2. Найти "GitHub Copilot"
3. Install
4. Sign in with GitHub

**Проверка лицензии:**
- Требуется активная подписка GitHub Copilot
- Или GitHub Pro/Team/Enterprise
- Или студенческий/учительский план

### Использование

**Inline suggestions:**
- Начните писать код
- Copilot автоматически предложит продолжение
- Tab - принять предложение
- Alt+] - следующее предложение
- Alt+[ - предыдущее предложение
- Esc - отклонить

**Copilot Chat:**
1. Откройте Copilot Chat панель (иконка в левой панели)
2. Задайте вопрос: "How to create a REST API in Express?"
3. Получите объяснения и примеры кода

**Генерация тестов:**
```javascript
// Выделите функцию
function add(a, b) {
  return a + b;
}

// В Copilot Chat: "Generate unit tests for this function"
```

## ☁️ Google Cloud AI

### Vertex AI

**Настройка credentials:**
```bash
# Авторизация через gcloud
gcloud auth application-default login

# Или через service account
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

**Пример использования (Python):**
```python
from google.cloud import aiplatform

# Инициализация
aiplatform.init(
    project="viktor-integration",
    location="us-central1"
)

# Использование модели
# (см. docs/google-ai-integration.md для деталей)
```

**Тестирование подключения:**
```bash
# Запустить helper скрипт
python3 scripts/ai-helpers/test-vertex-ai.py
```

### Gemini API

**Настройка API key:**
```bash
# Добавить в .env
echo "GOOGLE_API_KEY=your-api-key-here" >> ~/.env

# Загрузить в сессии
export GOOGLE_API_KEY="your-api-key-here"
```

**Пример использования (Python):**
```python
import google.generativeai as genai
import os

genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
model = genai.GenerativeModel('gemini-pro')

response = model.generate_content("Hello!")
print(response.text)
```

**Тестирование:**
```bash
# Запустить helper скрипт
python3 scripts/ai-helpers/test-gemini.py
```

## 📊 Мониторинг системы

### Проверка ресурсов

**htop (интерактивный):**
```bash
htop
```
- F5: Tree view
- F6: Sort by
- q: Quit

**btop (современный):**
```bash
btop
```
- Более красивый интерфейс
- Графики в реальном времени

**Использование диска:**
```bash
# Общая информация
df -h

# Интерактивный анализ
ncdu /

# Размер текущей директории
du -sh .

# Топ-10 больших файлов
du -ah . | sort -rh | head -10
```

**Docker статистика:**
```bash
# Ресурсы контейнеров
docker stats

# Размер образов
docker images

# Использование диска Docker
docker system df
```

### Логи

**Системные логи:**
```bash
# Все логи
journalctl

# Последние 100 строк
journalctl -n 100

# Следить в реальном времени
journalctl -f

# Логи конкретного сервиса
journalctl -u code-server

# За последний час
journalctl --since "1 hour ago"
```

**code-server логи:**
```bash
# Через journalctl
journalctl -u code-server -f

# Или напрямую (если логируется в файл)
tail -f ~/.local/share/code-server/coder-logs/*.log
```

## 🔐 Безопасность

### Пароли и ключи

**Изменение пароля code-server:**
```bash
# Сгенерировать новый пароль
openssl rand -base64 32

# Отредактировать конфигурацию
nano ~/.config/code-server/config.yaml

# Перезапустить сервис
sudo systemctl restart code-server
```

**SSH ключи для Git:**
```bash
# Сгенерировать SSH ключ
ssh-keygen -t ed25519 -C "your-email@example.com"

# Скопировать публичный ключ
cat ~/.ssh/id_ed25519.pub

# Добавить в GitHub: Settings → SSH and GPG keys → New SSH key
```

**Безопасное хранение секретов:**
```bash
# Использовать .env файлы
echo "API_KEY=secret" >> ~/.env

# НЕ коммитить .env в Git
echo ".env" >> .gitignore

# Загрузить в текущей сессии
source ~/.env
```

### Обновления

**Автоматические обновления безопасности:**
```bash
# Статус unattended-upgrades
sudo systemctl status unattended-upgrades

# Логи
sudo cat /var/log/unattended-upgrades/unattended-upgrades.log
```

**Ручное обновление:**
```bash
# Обновить все компоненты
sudo bash scripts/management/update-all.sh
```

## 💾 Backup и восстановление

### Автоматические бэкапы

**Проверка статуса:**
```bash
# Статус timer
sudo systemctl status backup.timer

# Последний запуск
sudo journalctl -u backup.service -n 50

# Список бэкапов
ls -lh /backup/
```

### Ручной бэкап

```bash
# Создать бэкап сейчас
sudo bash scripts/management/backup.sh

# Проверить созданный архив
ls -lh /backup/
tar -tzf /backup/projects_YYYYMMDD_HHMMSS.tar.gz | head -20
```

### Восстановление

```bash
# Список доступных бэкапов
ls -lh /backup/

# Восстановить из конкретного бэкапа
sudo bash scripts/management/restore.sh /backup/projects_20260108_120000.tar.gz

# Скрипт автоматически:
# 1. Остановит code-server
# 2. Создаст резервную копию текущих файлов
# 3. Восстановит файлы из архива
# 4. Запустит code-server
```

## 🛠️ Troubleshooting

### code-server не отвечает

```bash
# Проверить статус
sudo systemctl status code-server

# Перезапустить
sudo systemctl restart code-server

# Проверить логи
journalctl -u code-server -n 100
```

### Недостаточно места

```bash
# Проверить использование
df -h

# Найти большие файлы
ncdu /

# Очистить Docker
docker system prune -a

# Удалить старые бэкапы (старше 7 дней)
find /backup/ -name "projects_*.tar.gz" -mtime +7 -delete
```

### Git проблемы

```bash
# Сбросить credentials
gh auth logout
gh auth login

# Проверить SSH подключение к GitHub
ssh -T git@github.com

# Сбросить конфигурацию Git
git config --global --unset-all user.name
git config --global --unset-all user.email
```

Для других проблем см. [troubleshooting.md](troubleshooting.md).

## 📚 Дополнительные ресурсы

- [VS Code Documentation](https://code.visualstudio.com/docs)
- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [Google Cloud AI Documentation](https://cloud.google.com/ai)
- [Docker Documentation](https://docs.docker.com)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com)

## 💡 Tips & Tricks

### Производительность

1. **Отключайте неиспользуемые расширения**
   - File → Preferences → Extensions
   - Отключить вместо удаления

2. **Используйте .gitignore**
   - Исключайте node_modules, venv, build artifacts
   - Уменьшает загрузку workspace

3. **Закрывайте неиспользуемые файлы**
   - Каждый открытый файл использует память
   - View → Editor Layout → Close All

### Shortcuts

**Основные:**
- `Ctrl+P` - Quick file open
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+B` - Toggle sidebar
- `Ctrl+`` - Toggle terminal
- `Ctrl+/` - Toggle comment
- `Ctrl+D` - Select next occurrence
- `Alt+Up/Down` - Move line up/down
- `Shift+Alt+Up/Down` - Duplicate line

**Multi-cursor:**
- `Alt+Click` - Add cursor
- `Ctrl+Alt+Up/Down` - Add cursor above/below
- `Ctrl+Shift+L` - Select all occurrences

**Terminal:**
- `Ctrl+Shift+`` - New terminal
- `Ctrl+Shift+5` - Split terminal
- `Alt+Left/Right` - Switch terminal

### Workflow

1. **Используйте tmux для долгих процессов**
   ```bash
   tmux new -s build
   npm run build  # Может занять долго
   # Ctrl+b d для отключения
   # Процесс продолжится в фоне
   ```

2. **Настройте задачи в VS Code**
   - Terminal → Configure Tasks
   - Автоматизируйте build, test, deploy

3. **Используйте snippets**
   - File → Preferences → User Snippets
   - Создайте свои шаблоны кода

---

**Вы готовы к продуктивной разработке! 🚀**
