# Интеграция с Google AI

Полное руководство по использованию Google Cloud AI сервисов из Virtual Desktop Server.

## 🎯 Обзор

Google Cloud предоставляет мощные AI/ML сервисы:

- **Vertex AI:** Платформа для обучения и развертывания ML моделей
- **Gemini API:** Generative AI для текста, изображений, кода
- **Cloud AI APIs:** Vision, NLP, Translation, Speech и др.

## 🔧 Предварительная настройка

### 1. Google Cloud SDK

SDK уже установлен скриптом `05-google-cloud-sdk.sh`. Проверка:

```bash
# Проверить установку
gcloud --version

# Должно показать:
# Google Cloud SDK 4xx.x.x
# ...
```

### 2. Аутентификация

Есть два способа аутентификации:

#### Способ 1: Application Default Credentials (рекомендуется для разработки)

```bash
# Авторизация через браузер
gcloud auth application-default login

# Выберите Google аккаунт
# Разрешите доступ
```

**Credentials сохранены в:**
```
~/.config/gcloud/application_default_credentials.json
```

#### Способ 2: Service Account (рекомендуется для production)

**Создание Service Account:**

1. Откройте [GCP Console](https://console.cloud.google.com)
2. IAM & Admin → Service Accounts
3. Create Service Account
   - Name: `virtual-desktop-ai`
   - Description: `AI access for virtual desktop`
4. Grant roles:
   - `Vertex AI User`
   - `AI Platform Developer`
   - (Другие по необходимости)
5. Create Key → JSON
6. Скачайте JSON файл

**Настройка на сервере:**

```bash
# Создать директорию для credentials
mkdir -p ~/.config/gcloud

# Загрузить JSON файл на сервер (через scp или другим способом)
scp service-account-key.json vik9541@34.46.96.77:~/.config/gcloud/

# Установить переменную окружения
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/service-account-key.json"' >> ~/.bashrc
source ~/.bashrc

# Активировать service account
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Установить проект по умолчанию
gcloud config set project viktor-integration
```

### 3. Включение API

```bash
# Vertex AI API
gcloud services enable aiplatform.googleapis.com

# Generative AI API (Gemini)
gcloud services enable generativelanguage.googleapis.com

# Другие AI APIs
gcloud services enable vision.googleapis.com
gcloud services enable language.googleapis.com
gcloud services enable translate.googleapis.com
```

### 4. Установка библиотек

Библиотеки уже установлены, но можно обновить:

**Python:**
```bash
pip install --upgrade google-cloud-aiplatform google-generativeai vertexai
```

**Node.js:**
```bash
npm install -g @google-cloud/aiplatform @google/generative-ai
```

## 🤖 Vertex AI

### Основные концепции

**Vertex AI Platform:**
- Единая платформа для ML lifecycle
- Обучение моделей
- Развертывание моделей
- Мониторинг и управление

**Основные компоненты:**
- **Datasets:** Управление данными
- **Training:** Обучение моделей
- **Models:** Хранение моделей
- **Endpoints:** Развертывание для inference
- **Pipelines:** ML pipelines

### Python SDK

#### Инициализация

```python
from google.cloud import aiplatform

# Инициализация с явными параметрами
aiplatform.init(
    project="viktor-integration",
    location="us-central1",
    staging_bucket="gs://your-bucket"  # Опционально
)
```

#### Использование предобученных моделей

**Text Generation (PaLM 2):**
```python
from vertexai.language_models import TextGenerationModel

# Загрузить модель
model = TextGenerationModel.from_pretrained("text-bison@002")

# Генерация текста
response = model.predict(
    prompt="Write a Python function to calculate fibonacci numbers",
    temperature=0.7,
    max_output_tokens=1024,
    top_k=40,
    top_p=0.95,
)

print(response.text)
```

**Chat (PaLM 2):**
```python
from vertexai.language_models import ChatModel

# Загрузить chat модель
chat_model = ChatModel.from_pretrained("chat-bison@002")

# Начать чат
chat = chat_model.start_chat()

# Отправить сообщение
response = chat.send_message("Hello! Can you help me with Python?")
print(response.text)

# Продолжить диалог
response = chat.send_message("How do I read a CSV file?")
print(response.text)
```

**Code Generation (Codey):**
```python
from vertexai.language_models import CodeGenerationModel

# Загрузить code модель
code_model = CodeGenerationModel.from_pretrained("code-bison@002")

# Генерация кода
response = code_model.predict(
    prefix="def reverse_string(s):",
    max_output_tokens=256,
)

print(response.text)
```

**Code Chat:**
```python
from vertexai.language_models import CodeChatModel

code_chat_model = CodeChatModel.from_pretrained("codechat-bison@002")
code_chat = code_chat_model.start_chat()

response = code_chat.send_message("How do I authenticate with Google Cloud in Python?")
print(response.text)
```

#### Обучение кастомной модели

**AutoML Tables:**
```python
from google.cloud import aiplatform

# Создать dataset
dataset = aiplatform.TabularDataset.create(
    display_name="my-dataset",
    gcs_source="gs://my-bucket/data.csv",
)

# Запустить обучение
job = aiplatform.AutoMLTabularTrainingJob(
    display_name="my-training-job",
    optimization_prediction_type="regression",
    optimization_objective="minimize-rmse",
)

model = job.run(
    dataset=dataset,
    target_column="price",
    training_fraction_split=0.8,
    validation_fraction_split=0.1,
    test_fraction_split=0.1,
    model_display_name="my-model",
)
```

**Custom Training:**
```python
from google.cloud import aiplatform

# Создать custom training job
job = aiplatform.CustomTrainingJob(
    display_name="my-custom-training",
    script_path="train.py",
    container_uri="gcr.io/cloud-aiplatform/training/tf-cpu.2-12:latest",
    requirements=["pandas", "numpy", "scikit-learn"],
)

model = job.run(
    dataset=dataset,
    replica_count=1,
    machine_type="n1-standard-4",
    accelerator_type="NVIDIA_TESLA_T4",
    accelerator_count=1,
)
```

#### Развертывание модели

```python
# Создать endpoint
endpoint = aiplatform.Endpoint.create(
    display_name="my-endpoint",
)

# Развернуть модель
endpoint.deploy(
    model=model,
    deployed_model_display_name="my-deployed-model",
    machine_type="n1-standard-4",
    min_replica_count=1,
    max_replica_count=5,
)

# Сделать prediction
instances = [{"feature1": 1.0, "feature2": 2.0}]
predictions = endpoint.predict(instances=instances)
print(predictions)
```

### Node.js SDK

#### Инициализация

```javascript
const aiplatform = require('@google-cloud/aiplatform');
const {PredictionServiceClient} = aiplatform.v1;

const client = new PredictionServiceClient({
  apiEndpoint: 'us-central1-aiplatform.googleapis.com',
});

const project = 'viktor-integration';
const location = 'us-central1';
```

#### Prediction

```javascript
async function predictCustomModel() {
  const endpoint = `projects/${project}/locations/${location}/endpoints/${endpointId}`;
  
  const instance = {
    feature1: 1.0,
    feature2: 2.0,
  };
  
  const instanceValue = helpers.toValue(instance);
  const instances = [instanceValue];
  
  const request = {
    endpoint,
    instances,
  };
  
  const [response] = await client.predict(request);
  console.log('Predictions:', response.predictions);
}
```

### Helper скрипт для тестирования

**Файл:** `scripts/ai-helpers/test-vertex-ai.py`

```python
#!/usr/bin/env python3
"""
Test script for Vertex AI connection and basic operations.
"""

from google.cloud import aiplatform
import sys

def test_initialization():
    """Test Vertex AI initialization"""
    try:
        aiplatform.init(
            project="viktor-integration",
            location="us-central1"
        )
        print("✅ Vertex AI initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize Vertex AI: {e}")
        return False

def test_list_models():
    """List available models"""
    try:
        models = aiplatform.Model.list()
        print(f"✅ Found {len(models)} models")
        for model in models[:5]:  # Show first 5
            print(f"  - {model.display_name}")
        return True
    except Exception as e:
        print(f"❌ Failed to list models: {e}")
        return False

def test_text_generation():
    """Test text generation with PaLM 2"""
    try:
        from vertexai.language_models import TextGenerationModel
        
        model = TextGenerationModel.from_pretrained("text-bison@002")
        response = model.predict("Say hello in 3 languages", max_output_tokens=100)
        
        print("✅ Text generation test successful")
        print(f"Response: {response.text}")
        return True
    except Exception as e:
        print(f"⚠️  Text generation test skipped or failed: {e}")
        return False

def main():
    print("=" * 60)
    print("Vertex AI Connection Test")
    print("=" * 60)
    
    tests = [
        ("Initialization", test_initialization),
        ("List Models", test_list_models),
        ("Text Generation", test_text_generation),
    ]
    
    results = []
    for name, test_func in tests:
        print(f"\nTesting: {name}")
        print("-" * 60)
        results.append(test_func())
    
    print("\n" + "=" * 60)
    print(f"Tests passed: {sum(results)}/{len(results)}")
    print("=" * 60)
    
    return 0 if all(results[:2]) else 1  # First 2 tests are critical

if __name__ == "__main__":
    sys.exit(main())
```

**Запуск:**
```bash
python3 scripts/ai-helpers/test-vertex-ai.py
```

## 🌟 Gemini API

### Получение API ключа

1. Откройте [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create API Key
3. Скопируйте ключ

**Сохранение:**
```bash
# Добавить в .env
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.env

# Загрузить в сессию
source ~/.env
```

### Python SDK

#### Базовое использование

```python
import google.generativeai as genai
import os

# Настройка API ключа
genai.configure(api_key=os.environ['GOOGLE_API_KEY'])

# Создать модель
model = genai.GenerativeModel('gemini-pro')

# Генерация контента
response = model.generate_content("Explain quantum computing in simple terms")
print(response.text)
```

#### Чат

```python
model = genai.GenerativeModel('gemini-pro')
chat = model.start_chat(history=[])

response = chat.send_message("Hello! I'm learning Python.")
print(response.text)

response = chat.send_message("Can you give me a beginner project idea?")
print(response.text)

# Посмотреть историю
for message in chat.history:
    print(f"{message.role}: {message.parts[0].text}")
```

#### Multimodal (Gemini Pro Vision)

```python
import PIL.Image

model = genai.GenerativeModel('gemini-pro-vision')

# Загрузить изображение
img = PIL.Image.open('image.jpg')

# Анализировать изображение
response = model.generate_content([
    "What's in this image? Describe in detail.",
    img
])

print(response.text)
```

#### Streaming

```python
model = genai.GenerativeModel('gemini-pro')

response = model.generate_content(
    "Write a story about a robot learning to code",
    stream=True
)

for chunk in response:
    print(chunk.text, end='')
```

#### Safety Settings

```python
from google.generativeai.types import HarmCategory, HarmBlockThreshold

model = genai.GenerativeModel('gemini-pro')

response = model.generate_content(
    "Your prompt here",
    safety_settings={
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
    }
)
```

### Node.js SDK

```javascript
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

async function run() {
  const model = genAI.getGenerativeModel({ model: "gemini-pro" });

  const prompt = "Explain async/await in JavaScript";
  const result = await model.generateContent(prompt);
  const response = await result.response;
  const text = response.text();
  
  console.log(text);
}

run();
```

### Helper скрипт для тестирования

**Файл:** `scripts/ai-helpers/test-gemini.py`

```python
#!/usr/bin/env python3
"""
Test script for Gemini API.
Requires GOOGLE_API_KEY environment variable.
"""

import google.generativeai as genai
import os
import sys

def check_api_key():
    """Check if API key is configured"""
    api_key = os.environ.get('GOOGLE_API_KEY')
    if not api_key:
        print("❌ GOOGLE_API_KEY not set")
        print("Set it with: export GOOGLE_API_KEY='your-key'")
        return False
    
    print("✅ API key found")
    return True

def test_text_generation():
    """Test basic text generation"""
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        
        response = model.generate_content("Say hello in 3 languages")
        
        print("✅ Text generation successful")
        print(f"Response: {response.text}")
        return True
    except Exception as e:
        print(f"❌ Text generation failed: {e}")
        return False

def test_chat():
    """Test chat functionality"""
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        chat = model.start_chat(history=[])
        
        response = chat.send_message("What is 2+2?")
        
        print("✅ Chat test successful")
        print(f"Response: {response.text}")
        return True
    except Exception as e:
        print(f"❌ Chat test failed: {e}")
        return False

def main():
    print("=" * 60)
    print("Gemini API Test")
    print("=" * 60)
    
    if not check_api_key():
        return 1
    
    tests = [
        ("Text Generation", test_text_generation),
        ("Chat", test_chat),
    ]
    
    results = []
    for name, test_func in tests:
        print(f"\nTesting: {name}")
        print("-" * 60)
        results.append(test_func())
    
    print("\n" + "=" * 60)
    print(f"Tests passed: {sum(results)}/{len(results)}")
    print("=" * 60)
    
    return 0 if all(results) else 1

if __name__ == "__main__":
    sys.exit(main())
```

**Запуск:**
```bash
export GOOGLE_API_KEY="your-key"
python3 scripts/ai-helpers/test-gemini.py
```

## 💡 Примеры использования

### Code Assistant

```python
import google.generativeai as genai

genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
model = genai.GenerativeModel('gemini-pro')

def code_helper(task):
    """Helper function for coding tasks"""
    prompt = f"""
    Task: {task}
    
    Please provide:
    1. Brief explanation
    2. Code example
    3. Best practices
    """
    
    response = model.generate_content(prompt)
    return response.text

# Использование
result = code_helper("How to implement a binary search in Python?")
print(result)
```

### Documentation Generator

```python
def generate_docstring(function_code):
    """Generate docstring for Python function"""
    prompt = f"""
    Generate a comprehensive docstring for this Python function:
    
    {function_code}
    
    Include:
    - Description
    - Args
    - Returns
    - Raises (if applicable)
    - Example usage
    """
    
    response = model.generate_content(prompt)
    return response.text

# Пример
code = """
def calculate_discount(price, discount_percent):
    return price * (1 - discount_percent / 100)
"""

docstring = generate_docstring(code)
print(docstring)
```

### Data Analysis Assistant

```python
from vertexai.language_models import TextGenerationModel
import pandas as pd

def analyze_dataset(df, question):
    """Ask questions about your dataset"""
    # Получить summary датасета
    summary = f"""
    Dataset shape: {df.shape}
    Columns: {df.columns.tolist()}
    Sample data:\n{df.head().to_string()}
    """
    
    model = TextGenerationModel.from_pretrained("text-bison@002")
    
    prompt = f"""
    Dataset information:
    {summary}
    
    Question: {question}
    
    Provide analysis and Python code if needed.
    """
    
    response = model.predict(prompt, max_output_tokens=1024)
    return response.text

# Использование
df = pd.read_csv('data.csv')
analysis = analyze_dataset(df, "What are the trends in this data?")
print(analysis)
```

## 📊 Квоты и лимиты

### Vertex AI

**Free tier (каждый месяц):**
- Text: 1000 predictions
- Chat: 1000 messages
- Code: 500 predictions

**Pricing (после free tier):**
- Text: $0.0005/1000 characters
- Chat: $0.0005/message
- Code: $0.001/prediction

**Rate limits:**
- 60 requests/minute (default)
- Можно увеличить по запросу

### Gemini API

**Free tier:**
- 60 requests/minute
- 1500 requests/day

**Paid tier:**
- Более высокие лимиты
- SLA guarantees

## 🐛 Troubleshooting

### Authentication Errors

**Problem:** `PermissionDenied` или `Unauthenticated`

**Solutions:**
```bash
# 1. Проверить authentication
gcloud auth list

# 2. Проверить Application Default Credentials
gcloud auth application-default print-access-token

# 3. Если используется service account, проверить
echo $GOOGLE_APPLICATION_CREDENTIALS
cat $GOOGLE_APPLICATION_CREDENTIALS  # Должен быть валидный JSON

# 4. Проверить роли в GCP Console
# IAM & Admin → IAM → найти свой service account
# Должен иметь роль "Vertex AI User" или "AI Platform Developer"
```

### API Not Enabled

**Problem:** `API [aiplatform.googleapis.com] not enabled`

**Solution:**
```bash
# Включить API
gcloud services enable aiplatform.googleapis.com
gcloud services enable generativelanguage.googleapis.com

# Проверить включенные APIs
gcloud services list --enabled | grep ai
```

### Quota Exceeded

**Problem:** `Quota exceeded for quota metric 'Predictions per minute'`

**Solutions:**
```bash
# 1. Проверить текущие квоты
gcloud compute project-info describe --project=viktor-integration

# 2. Запросить увеличение в GCP Console:
# IAM & Admin → Quotas → Filter by "Vertex AI" → Request increase

# 3. Добавить retry logic в код
from time import sleep

def predict_with_retry(endpoint, instances, max_retries=3):
    for i in range(max_retries):
        try:
            return endpoint.predict(instances=instances)
        except Exception as e:
            if "quota" in str(e).lower() and i < max_retries - 1:
                sleep(2 ** i)  # Exponential backoff
                continue
            raise
```

### Import Errors

**Problem:** `ModuleNotFoundError: No module named 'google.cloud'`

**Solution:**
```bash
# Переустановить библиотеки
pip install --upgrade google-cloud-aiplatform google-generativeai vertexai

# Проверить установку
python3 -c "import google.cloud.aiplatform; print('OK')"
```

## 📚 Дополнительные ресурсы

- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Google AI Studio](https://makersuite.google.com/)
- [Vertex AI Samples](https://github.com/GoogleCloudPlatform/vertex-ai-samples)
- [Pricing Calculator](https://cloud.google.com/products/calculator)

---

**Используйте Google AI для ускорения разработки! 🚀**
