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
  default     = 1000
}
