variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "viktor-integration"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP Machine Type"
  type        = string
  default     = "e2-highmem-8"  # 8 vCPU, 64GB RAM
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 500
}

variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = "virtual-desktop-server"
}

variable "username" {
  description = "Primary username for the server"
  type        = string
  default     = "vik9541"
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "alert_email" {
  description = "Email for monitoring alerts"
  type        = string
}

variable "enable_persistent_disk" {
  description = "Enable additional persistent disk for /data/shared"
  type        = bool
  default     = true
}

variable "persistent_disk_size_gb" {
  description = "Persistent disk size in GB"
  type        = number
  default     = 200  # Reduced due to GCP quota limit (500GB total SSD per region)
}

# ============================================================
# SECURITY: IP Whitelist Configuration
# IPs from Terraform_VPS_VPN project + admin access
# ============================================================

variable "ssh_allowed_ips" {
  description = "IP addresses allowed to SSH (from VPN servers and admin)"
  type        = list(string)
  default = [
    # DigitalOcean VPN Servers
    "146.190.147.78/32",   # USA VPN
    "165.232.153.33/32",   # API Server / WireGuard
    "165.232.145.104/32",  # Staging / Web Server 2
    "134.199.137.209/32",  # Load Balancer
    "164.92.67.148/32",    # Prometheus
    "157.245.157.120/32",  # VPN endpoint
    "178.62.83.243/32",    # VPN endpoint
    "64.227.32.80/32",     # VPN endpoint
    "24.199.72.162/32",    # VPN endpoint
    "147.182.231.197/32",  # VPN endpoint
    # Yandex Cloud
    "158.160.150.162/32",  # Yandex Cloud VPN
    "84.252.133.240/32",   # Yandex Cloud
    # Hetzner
    "185.154.194.145/32",  # Hetzner VPN
    # Other infrastructure
    "107.170.38.83/32",    # Monitoring
    "128.199.193.67/32",   # Backup
    "163.47.8.152/32",     # Asia endpoint
    "209.38.160.193/32",   # Control plane
    "31.173.84.228/32",    # Russia
    "63.143.42.240/32",    # Additional
    "69.162.124.224/32",   # Additional
  ]
}

variable "code_server_allowed_ips" {
  description = "IP addresses allowed to access code-server"
  type        = list(string)
  default = [
    # VPN exit nodes (users connect via VPN)
    "146.190.147.78/32",   # USA VPN
    "165.232.153.33/32",   # API Server / WireGuard  
    "165.232.145.104/32",  # Staging
    "158.160.150.162/32",  # Yandex Cloud VPN
    "84.252.133.240/32",   # Yandex Cloud
    "185.154.194.145/32",  # Hetzner VPN
    "31.173.84.228/32",    # Russia
  ]
}

variable "https_allowed_ips" {
  description = "IP addresses allowed HTTPS access"
  type        = list(string)
  default = [
    # Same as code_server for consistency
    "146.190.147.78/32",   # USA VPN
    "165.232.153.33/32",   # API Server / WireGuard
    "165.232.145.104/32",  # Staging
    "158.160.150.162/32",  # Yandex Cloud VPN
    "84.252.133.240/32",   # Yandex Cloud
    "185.154.194.145/32",  # Hetzner VPN
    "31.173.84.228/32",    # Russia
  ]
}
