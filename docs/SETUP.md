# Настройка окружения для Virtual Desktop Server

## Сервер GCP

- **Проект:** viktor-integration
- **Инстанс:** instance-20260108-163425
- **Зона:** us-central1-a
- **Консоль:** https://console.cloud.google.com/compute/instancesDetail/zones/us-central1-a/instances/instance-20260108-163425?project=viktor-integration

## Требования

- Terraform >= 1.7.0
- Google Cloud SDK
- SSH ключ

## 1. SSH ключ

### Генерация нового ключа (если нет):

```bash
# Windows PowerShell / Linux / macOS
ssh-keygen -t rsa -b 4096 -C "vik9541@virtual-desktop"

# Просмотр публичного ключа (понадобится для terraform.tfvars)
cat ~/.ssh/id_rsa.pub
```

## 2. Установка Google Cloud SDK

### Windows:
```powershell
winget install Google.CloudSDK
```

### macOS:
```bash
brew install google-cloud-sdk
```

### Linux:
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

## 3. Настройка gcloud

```bash
# Проверить текущий проект
gcloud config get-value project

# Установить проект
gcloud config set project viktor-integration

# Аутентификация
gcloud auth login

# Аутентификация для Terraform (Application Default Credentials)
gcloud auth application-default login
```

## 4. Установка Terraform

### Windows:
```powershell
winget install Hashicorp.Terraform
```

### macOS:
```bash
brew install terraform
```

### Linux:
```bash
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Проверка:
```bash
terraform version
```

## 5. Подключение к серверу по SSH

```bash
gcloud compute ssh instance-20260108-163425 --zone=us-central1-a --project=viktor-integration
```

Или напрямую:
```bash
ssh -i ~/.ssh/id_rsa <username>@<external-ip>
```
