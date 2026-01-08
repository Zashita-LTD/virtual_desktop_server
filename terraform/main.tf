# Virtual Desktop Server - Terraform Configuration
# GCP infrastructure for development environment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Compute Instance
resource "google_compute_instance" "virtual_desktop" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["code-server", "development"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral public IP (or specify nat_ip for static IP)
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")

  labels = {
    environment = "development"
    managed-by  = "terraform"
    owner       = "vik9541"
  }
}

# Static IP (optional)
resource "google_compute_address" "static_ip" {
  count = var.use_static_ip ? 1 : 0
  
  name   = "${var.instance_name}-ip"
  region = var.region
}

# Output values
output "instance_name" {
  value       = google_compute_instance.virtual_desktop.name
  description = "Name of the compute instance"
}

output "instance_ip" {
  value       = google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip
  description = "External IP address of the instance"
}

output "instance_zone" {
  value       = google_compute_instance.virtual_desktop.zone
  description = "Zone of the instance"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${google_compute_instance.virtual_desktop.name} --zone=${var.zone}"
  description = "Command to SSH into the instance"
}

output "code_server_url" {
  value       = "https://${google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip}:8443"
  description = "URL to access code-server"
}
