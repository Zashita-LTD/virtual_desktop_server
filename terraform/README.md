# Terraform Configuration for Virtual Desktop Server

This Terraform configuration automatically deploys a complete virtual desktop development server on Google Cloud Platform.

## Prerequisites

1. **Google Cloud SDK** installed and authenticated:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Terraform** installed (v1.0+):
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **SSH Key** generated:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "vik9541@virtual-desktop"
   cat ~/.ssh/id_rsa.pub  # Copy this for terraform.tfvars
   ```

## Quick Start

### 1. Configure Variables

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Update with your values:
- `ssh_public_key` - Your SSH public key
- `alert_email` - Your email for alerts
- Adjust `machine_type`, `disk_size_gb` if needed

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review Plan

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

Type `yes` when prompted.

⏱️ **Deployment time:** ~30-40 minutes (includes OS installation + all software)

### 5. Monitor Installation

```bash
# Get the SSH command from outputs
terraform output ssh_command

# Check installation progress
gcloud compute ssh virtual-desktop-server \
  --zone=us-central1-a \
  --project=viktor-integration \
  --command='tail -f /var/log/startup-script.log'
```

### 6. Access code-server

```bash
# Get the URL
terraform output code_server_url

# Get the password
terraform output installation_status_command
# Then run: cat ~/.config/code-server/config.yaml
```

## What Gets Deployed

- ✅ GCP Compute Instance (e2-highmem-8: 8 vCPU, 64GB RAM)
- ✅ Static External IP
- ✅ Service Account with AI/Logging/Monitoring permissions
- ✅ Firewall rules (SSH, HTTPS, code-server)
- ✅ Optional 1TB SSD persistent disk for /data/shared
- ✅ Automated installation of all components:
  - code-server (VS Code in browser)
  - Dev tools (Git, Docker, Node, Python, Go, Rust)
  - Google Cloud SDK + AI libraries
  - Security (UFW, fail2ban, SSL)
  - Monitoring (Cloud Ops Agent)
  - 5 pre-configured workspaces

## Outputs

After `terraform apply`, you'll get:

```
external_ip               = "34.xxx.xxx.xxx"
code_server_url           = "https://34.xxx.xxx.xxx:8443"
ssh_command               = "gcloud compute ssh ..."
service_account_email     = "virtual-desktop-server-sa@..."
installation_status_command = "gcloud compute ssh ... tail -f /var/log/startup-script.log"
next_steps                = "Detailed next steps..."
```

## Customization

### Change Machine Type

Edit `terraform.tfvars`:
```hcl
machine_type = "e2-highmem-16"  # 16 vCPU, 128GB RAM
```

### Change Region/Zone

```hcl
region = "us-west1"
zone   = "us-west1-a"
```

### Disable Persistent Disk

```hcl
enable_persistent_disk = false
```

## Updating Infrastructure

```bash
# Modify terraform.tfvars or *.tf files
terraform plan
terraform apply
```

## Destroying

⚠️ **Warning:** This will delete the instance and all data!

```bash
terraform destroy
```

To keep persistent disk data, remove it from state first:
```bash
terraform state rm google_compute_disk.data_disk[0]
terraform destroy
```

## Troubleshooting

### Installation Failed

Check logs:
```bash
gcloud compute ssh virtual-desktop-server \
  --zone=us-central1-a \
  --command='cat /var/log/startup-script.log'
```

### Can't Access code-server

1. Check firewall:
   ```bash
   gcloud compute firewall-rules list
   ```

2. Check code-server status:
   ```bash
   gcloud compute ssh virtual-desktop-server \
     --command='systemctl status code-server@vik9541'
   ```

### SSH Connection Issues

Verify SSH key in metadata:
```bash
gcloud compute instances describe virtual-desktop-server \
  --zone=us-central1-a \
  --format="value(metadata.items.ssh-keys)"
```

## Cost Estimation

Estimated monthly cost (us-central1):
- e2-highmem-8: ~$260/month
- 500GB SSD boot disk: ~$85/month
- 1TB SSD persistent disk: ~$170/month
- Static IP: ~$7/month
- **Total: ~$520/month**

Reduce costs:
- Use preemptible instance (not recommended for dev server)
- Use standard persistent disk instead of SSD
- Reduce disk sizes

## Support

See main documentation:
- [Main README](../README.md)
- [Deployment Guide](../DEPLOYMENT.md)
- [Troubleshooting](../docs/troubleshooting.md)
