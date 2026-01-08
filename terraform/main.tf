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
  zone    = var.zone
}

# Static External IP
resource "google_compute_address" "static_ip" {
  name   = "${var.instance_name}-ip"
  region = var.region
}

# Service Account for the instance
resource "google_service_account" "instance_sa" {
  account_id   = "${var.instance_name}-sa"
  display_name = "Virtual Desktop Server Service Account"
  description  = "Service account for virtual desktop server with AI access"
}

# IAM roles for Service Account
resource "google_project_iam_member" "instance_sa_roles" {
  for_each = toset([
    "roles/aiplatform.user",           # Vertex AI
    "roles/logging.logWriter",          # Cloud Logging
    "roles/monitoring.metricWriter",    # Cloud Monitoring
    "roles/storage.objectAdmin",        # Cloud Storage for backups
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.instance_sa.email}"
}

# Optional: Persistent disk for /data/shared
resource "google_compute_disk" "data_disk" {
  count = var.enable_persistent_disk ? 1 : 0
  
  name  = "${var.instance_name}-data-disk"
  type  = "pd-ssd"
  zone  = var.zone
  size  = var.persistent_disk_size_gb
  
  labels = {
    environment = "production"
    purpose     = "workspace-storage"
  }
}

# Startup script that installs everything
data "template_file" "startup_script" {
  template = file("${path.module}/startup-script.sh")
  
  vars = {
    username    = var.username
    alert_email = var.alert_email
    project_id  = var.project_id
    region      = var.region
  }
}

# Main compute instance
resource "google_compute_instance" "virtual_desktop" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  
  tags = ["code-server", "virtual-desktop", "https-server"]
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }
  
  # Attach persistent disk if enabled
  dynamic "attached_disk" {
    for_each = var.enable_persistent_disk ? [1] : []
    content {
      source      = google_compute_disk.data_disk[0].id
      device_name = "data-disk"
    }
  }
  
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
  
  metadata = {
    ssh-keys = "${var.username}:${var.ssh_public_key}"
    startup-script = data.template_file.startup_script.rendered
  }
  
  metadata_startup_script = data.template_file.startup_script.rendered
  
  service_account {
    email  = google_service_account.instance_sa.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }
  
  labels = {
    environment = "production"
    type        = "virtual-desktop"
    managed-by  = "terraform"
  }
  
  # Allow stopping for updates
  allow_stopping_for_update = true
  
  # Lifecycle
  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}
