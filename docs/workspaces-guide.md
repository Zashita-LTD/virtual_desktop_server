# Работа с Workspaces

Подробное руководство по использованию multi-root workspaces в Virtual Desktop Server.

## 🎯 Концепция Workspaces

### Что такое VS Code Workspace?

VS Code Workspace - это коллекция папок и настроек, которые определяют рабочую среду для проекта или группы связанных проектов.

**Ключевые особенности:**
- **Multi-root:** Один workspace может содержать несколько корневых папок
- **Изолированные настройки:** Каждый workspace имеет свои настройки
- **Рекомендуемые расширения:** Автоматическая установка нужных расширений
- **Переменные окружения:** Специфичные для workspace переменные
- **Задачи:** Настроенные build/test/deploy задачи

### Зачем использовать Workspaces?

**Организация проектов:**
- Логическая группировка связанных проектов
- Разделение frontend/backend/infrastructure
- Разные настройки для разных типов работ

**Производительность:**
- VS Code индексирует только нужные папки
- Меньше памяти при работе над конкретной задачей
- Быстрее поиск файлов

**Переключение контекста:**
- Быстрое переключение между типами работ
- Сохранение открытых файлов и layout
- История команд для каждого workspace

## 📁 Структура Workspaces

### Обзор 5 Workspaces

```
/data/shared/projects/
├── workspace1-frontend/          # React, Vue, Angular
├── workspace2-backend/           # Node, Python, Go APIs
├── workspace3-ai-ml/             # ML, Data Science
├── workspace4-infrastructure/    # Terraform, K8s
└── workspace5-experiments/       # Prototyping
```

### 1. Frontend Workspace

**Файл:** `config/workspaces/workspace1-frontend.code-workspace`

**Назначение:**
- Single Page Applications (React, Vue, Angular)
- Static websites (HTML/CSS/JS)
- Component libraries
- UI/UX прототипы

**Типичные проекты:**
```
workspace1-frontend/
├── react-dashboard/
├── vue-landing-page/
├── component-library/
└── portfolio-site/
```

**Рекомендуемые расширения:**
- ESLint - JavaScript linting
- Prettier - Code formatting
- Live Server - Local development server
- Auto Rename Tag - HTML tag renaming
- CSS Peek - CSS definitions
- Tailwind CSS IntelliSense
- Vue/React/Angular extensions

**Настройки:**
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "eslint.autoFixOnSave": true,
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  }
}
```

### 2. Backend Workspace

**Файл:** `config/workspaces/workspace2-backend.code-workspace`

**Назначение:**
- REST APIs (Express, Fastify, Flask, FastAPI)
- GraphQL servers
- Microservices
- Database schemas

**Типичные проекты:**
```
workspace2-backend/
├── nodejs-api/
├── python-microservice/
├── go-grpc-service/
└── graphql-server/
```

**Рекомендуемые расширения:**
- Python
- Go
- REST Client - HTTP requests testing
- Thunder Client - API testing
- Database Client - SQL/NoSQL browsers
- Prisma - ORM support
- Docker

**Настройки:**
```json
{
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "go.useLanguageServer": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  }
}
```

### 3. AI/ML Workspace

**Файл:** `config/workspaces/workspace3-ai-ml.code-workspace`

**Назначение:**
- Machine Learning models
- Data Science projects
- Jupyter notebooks
- TensorFlow/PyTorch projects
- Vertex AI integrations

**Типичные проекты:**
```
workspace3-ai-ml/
├── image-classification/
├── nlp-sentiment-analysis/
├── recommendation-system/
└── vertex-ai-experiments/
```

**Рекомендуемые расширения:**
- Jupyter
- Python
- Pylance (Python language server)
- Data Wrangler
- Rainbow CSV
- TensorFlow Snippets

**Настройки:**
```json
{
  "jupyter.askForKernelRestart": false,
  "python.dataScience.askForKernelRestart": false,
  "python.analysis.extraPaths": [
    "/usr/local/lib/python3.12/site-packages"
  ]
}
```

### 4. Infrastructure Workspace

**Файл:** `config/workspaces/workspace4-infrastructure.code-workspace`

**Назначение:**
- Infrastructure as Code (Terraform, Pulumi)
- Kubernetes manifests
- Docker configurations
- CI/CD pipelines
- Ansible playbooks

**Типичные проекты:**
```
workspace4-infrastructure/
├── terraform-gcp/
├── k8s-manifests/
├── docker-images/
└── ansible-playbooks/
```

**Рекомендуемые расширения:**
- HashiCorp Terraform
- Kubernetes
- Docker
- YAML
- GitHub Actions
- Ansible

**Настройки:**
```json
{
  "terraform.languageServer": {
    "enabled": true,
    "args": []
  },
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  }
}
```

### 5. Experiments Workspace

**Файл:** `config/workspaces/workspace5-experiments.code-workspace`

**Назначение:**
- Proof of concepts
- Learning new technologies
- Quick prototypes
- Temporary projects

**Типичные проекты:**
```
workspace5-experiments/
├── rust-learning/
├── webassembly-test/
├── blockchain-poc/
└── random-scripts/
```

**Рекомендуемые расширения:**
- Общий набор для разных языков
- Language-specific по мере необходимости

**Настройки:**
```json
{
  "files.autoSave": "afterDelay",
  "editor.minimap.enabled": false
}
```

## 🔧 Создание и настройка Workspace

### Создание нового workspace

**Способ 1: Из существующей папки**
```bash
# 1. Создать директорию для workspace
mkdir -p /data/shared/projects/workspace6-mobile

# 2. Открыть папку в VS Code
# File → Open Folder → выбрать workspace6-mobile

# 3. Сохранить как workspace
# File → Save Workspace As...
# Сохранить как workspace6-mobile.code-workspace
```

**Способ 2: Используя скрипт**
```bash
# Создать workspace с базовой структурой
bash scripts/workspaces/create-workspace.sh workspace6-mobile

# Скрипт создаст:
# - Директорию в /data/shared/projects/
# - .code-workspace файл
# - .vscode/settings.json
# - README.md
```

**Способ 3: Вручную создать .code-workspace файл**
```json
{
  "folders": [
    {
      "name": "Mobile App",
      "path": "/data/shared/projects/workspace6-mobile"
    }
  ],
  "settings": {
    "editor.formatOnSave": true
  },
  "extensions": {
    "recommendations": [
      "msjsdiag.vscode-react-native"
    ]
  }
}
```

### Структура .code-workspace файла

**Минимальная структура:**
```json
{
  "folders": [],
  "settings": {},
  "extensions": {}
}
```

**Полная структура:**
```json
{
  "folders": [
    {
      "name": "Отображаемое имя",
      "path": "/absolute/path/to/folder"
    },
    {
      "name": "Второй проект",
      "path": "/path/to/another/folder"
    }
  ],
  "settings": {
    // Настройки для этого workspace
    "editor.tabSize": 2,
    "files.exclude": {
      "**/node_modules": true
    }
  },
  "extensions": {
    "recommendations": [
      "extension.id",
      "another.extension"
    ],
    "unwantedRecommendations": [
      "unwanted.extension"
    ]
  },
  "launch": {
    // Debug configurations
    "configurations": []
  },
  "tasks": {
    // Task configurations
    "tasks": []
  }
}
```

### Multi-root Workspaces

**Добавление нескольких проектов:**
```json
{
  "folders": [
    {
      "name": "Frontend",
      "path": "/data/shared/projects/workspace1-frontend/my-app"
    },
    {
      "name": "Backend",
      "path": "/data/shared/projects/workspace2-backend/my-api"
    },
    {
      "name": "Shared",
      "path": "/data/shared/projects/shared-components"
    }
  ]
}
```

**Преимущества multi-root:**
- Одновременная работа над frontend и backend
- Общий search/replace across projects
- Unified terminal для всех проектов
- Cross-project refactoring

## 🎨 Настройка Workspace

### Settings (Настройки)

**Уровни настроек (приоритет):**
1. Workspace settings (highest)
2. User settings
3. Default settings (lowest)

**Полезные настройки для workspace:**
```json
{
  "settings": {
    // Editor
    "editor.formatOnSave": true,
    "editor.tabSize": 2,
    "editor.rulers": [80, 120],
    
    // Files
    "files.autoSave": "afterDelay",
    "files.exclude": {
      "**/node_modules": true,
      "**/.git": true,
      "**/dist": true,
      "**/.venv": true
    },
    
    // Search
    "search.exclude": {
      "**/node_modules": true,
      "**/dist": true
    },
    
    // Terminal
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.fontSize": 14,
    
    // Language-specific
    "[javascript]": {
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[python]": {
      "editor.defaultFormatter": "ms-python.black-formatter",
      "editor.formatOnSave": true
    }
  }
}
```

### Extensions (Расширения)

**Рекомендуемые расширения:**
```json
{
  "extensions": {
    "recommendations": [
      // Базовые
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode",
      "eamodio.gitlens",
      
      // Language-specific
      "ms-python.python",
      "golang.go",
      
      // Utilities
      "christian-kohler.path-intellisense",
      "oderwat.indent-rainbow"
    ]
  }
}
```

**Установка рекомендуемых расширений:**
1. Открыть workspace
2. VS Code предложит установить рекомендуемые расширения
3. Или: Extensions → Show Recommended Extensions

### Tasks (Задачи)

**Создание задач для build/test:**
```json
{
  "tasks": {
    "version": "2.0.0",
    "tasks": [
      {
        "label": "npm: build",
        "type": "shell",
        "command": "npm run build",
        "group": {
          "kind": "build",
          "isDefault": true
        },
        "problemMatcher": ["$tsc"]
      },
      {
        "label": "npm: test",
        "type": "shell",
        "command": "npm test",
        "group": "test"
      }
    ]
  }
}
```

**Запуск задач:**
- Terminal → Run Task
- Ctrl+Shift+B (default build task)
- Ctrl+Shift+P → Tasks: Run Test Task

### Launch Configurations (Debug)

**Пример для Node.js:**
```json
{
  "launch": {
    "version": "0.2.0",
    "configurations": [
      {
        "type": "node",
        "request": "launch",
        "name": "Launch Program",
        "program": "${workspaceFolder}/index.js",
        "cwd": "${workspaceFolder}"
      }
    ]
  }
}
```

## 🔄 Workflow с Workspaces

### Ежедневный workflow

**Утро:**
```bash
# 1. SSH на сервер
ssh vik9541@34.46.96.77

# 2. Создать tmux сессию
tmux new -s dev

# 3. Открыть браузер → https://34.46.96.77:8443

# 4. Открыть workspace для сегодняшней задачи
# File → Open Recent → workspace2-backend
```

**Работа:**
- Открыть нужные файлы
- Запустить dev server в terminal
- Писать код с GitHub Copilot
- Коммитить изменения
- Push в GitHub

**Вечер:**
- Commit/push незаконченную работу
- File → Close Workspace (или просто закрыть браузер)
- tmux detach (Ctrl+b d)
- Выход из SSH

**На следующий день:**
- SSH на сервер
- tmux attach -t dev
- Открыть браузер → code-server
- Workspace и terminal sessions восстановлены!

### Переключение между задачами

**Frontend → Backend:**
```
1. Commit текущую работу
2. File → Open Recent → workspace2-backend
3. Все настройки автоматически переключатся
4. Terminal, Git, Extensions - все для backend
```

**Работа над связанными проектами:**
```
1. Создать multi-root workspace
2. Добавить frontend и backend папки
3. Работать над обоими одновременно
4. Cross-project search и refactoring
```

### Best Practices

**1. Организация проектов**
```
✅ DO:
- Группировать похожие проекты в один workspace
- Использовать понятные имена для folders
- Коммитить .code-workspace файлы в Git

❌ DON'T:
- Не добавлять слишком много папок (max 5-7)
- Не смешивать несвязанные проекты
- Не хранить абсолютные пути (используйте ${workspaceFolder})
```

**2. Настройки**
```
✅ DO:
- Использовать workspace settings для проект-специфичных настроек
- Делиться workspace файлами с командой
- Документировать нестандартные настройки

❌ DON'T:
- Не хранить секреты в настройках
- Не переопределять все настройки (только нужные)
```

**3. Расширения**
```
✅ DO:
- Рекомендовать только необходимые расширения
- Периодически обновлять список
- Тестировать новые расширения в experiments workspace

❌ DON'T:
- Не рекомендовать слишком много расширений (10-15 max)
- Не устанавливать конфликтующие расширения
```

## 📊 Примеры использования

### Пример 1: Full-stack приложение

**Структура:**
```
/data/shared/projects/
├── workspace1-frontend/
│   └── my-app-frontend/
└── workspace2-backend/
    └── my-app-backend/
```

**Workspace файл:**
```json
{
  "folders": [
    {
      "name": "Frontend",
      "path": "/data/shared/projects/workspace1-frontend/my-app-frontend"
    },
    {
      "name": "Backend",
      "path": "/data/shared/projects/workspace2-backend/my-app-backend"
    }
  ],
  "settings": {
    "search.exclude": {
      "**/node_modules": true
    }
  }
}
```

### Пример 2: Microservices

**Workspace для нескольких сервисов:**
```json
{
  "folders": [
    {
      "name": "Auth Service",
      "path": "/data/shared/projects/workspace2-backend/auth-service"
    },
    {
      "name": "User Service",
      "path": "/data/shared/projects/workspace2-backend/user-service"
    },
    {
      "name": "Payment Service",
      "path": "/data/shared/projects/workspace2-backend/payment-service"
    },
    {
      "name": "Shared Library",
      "path": "/data/shared/projects/workspace2-backend/shared-lib"
    }
  ]
}
```

### Пример 3: ML Pipeline

**Workspace для ML проекта:**
```json
{
  "folders": [
    {
      "name": "Data Processing",
      "path": "/data/shared/projects/workspace3-ai-ml/data-pipeline"
    },
    {
      "name": "Model Training",
      "path": "/data/shared/projects/workspace3-ai-ml/training"
    },
    {
      "name": "Model Serving",
      "path": "/data/shared/projects/workspace2-backend/ml-api"
    },
    {
      "name": "Notebooks",
      "path": "/data/shared/projects/workspace3-ai-ml/notebooks"
    }
  ],
  "settings": {
    "python.defaultInterpreterPath": "/usr/bin/python3.12"
  }
}
```

## 🛠️ Расширенные техники

### VS Code Profiles

**Создание профиля:**
1. File → Preferences → Profiles → Create Profile
2. Выбрать что включить (settings, extensions, keybindings)
3. Использовать разные профили для разных workspace types

**Профили для разных ролей:**
- **Frontend Developer:** React extensions, Prettier, ESLint
- **Backend Developer:** Python, Go, REST Client
- **DevOps Engineer:** Terraform, Kubernetes, Docker
- **Data Scientist:** Jupyter, Python Data Science

### Переменные в Workspace

**Доступные переменные:**
- `${workspaceFolder}` - Корень workspace
- `${workspaceFolderBasename}` - Имя папки
- `${file}` - Текущий файл
- `${fileBasename}` - Имя файла
- `${env:VAR}` - Переменная окружения

**Использование:**
```json
{
  "settings": {
    "python.pythonPath": "${workspaceFolder}/.venv/bin/python",
    "terminal.integrated.env.linux": {
      "PROJECT_ROOT": "${workspaceFolder}"
    }
  }
}
```

### Синхронизация настроек

**Settings Sync:**
1. File → Preferences → Turn on Settings Sync
2. Выбрать что синхронизировать
3. Войти через GitHub
4. Настройки доступны на любом устройстве

**Для команды:**
- Храните .code-workspace файлы в Git репозитории
- Используйте relative paths где возможно
- Документируйте workspace setup в README

## 📚 Дополнительные ресурсы

- [VS Code Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)
- [VS Code Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings)
- [VS Code Tasks](https://code.visualstudio.com/docs/editor/tasks)
- [VS Code Debugging](https://code.visualstudio.com/docs/editor/debugging)

---

**Workspaces помогают организовать работу и повысить продуктивность! 🚀**
