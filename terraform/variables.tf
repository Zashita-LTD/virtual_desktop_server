# Variables for Terraform configuration

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "viktor-integration"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-c"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "virtual-desktop-server"
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-highmem-8"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 500
}

variable "use_static_ip" {
  description = "Whether to use a static external IP"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Service account email for the instance"
  type        = string
  default     = "763289222664-compute@developer.gserviceaccount.com"
}

variable "allowed_ssh_ips" {
  description = "IP ranges allowed to SSH (CIDR notation)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Warning: Allow from anywhere. Restrict in production!
}

variable "allowed_https_ips" {
  description = "IP ranges allowed to access HTTPS (CIDR notation)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Warning: Allow from anywhere. Restrict in production!
}
