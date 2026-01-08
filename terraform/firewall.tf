# Firewall Rules for Virtual Desktop Server

# Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-virtual-desktop"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_ips
  target_tags   = ["code-server", "development"]

  description = "Allow SSH access to virtual desktop server"
}

# Allow HTTPS (for potential Nginx reverse proxy)
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https-virtual-desktop"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = var.allowed_https_ips
  target_tags   = ["code-server", "development"]

  description = "Allow HTTPS access to virtual desktop server"
}

# Allow code-server (port 8443)
resource "google_compute_firewall" "allow_code_server" {
  name    = "allow-code-server"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = var.allowed_https_ips
  target_tags   = ["code-server", "development"]

  description = "Allow access to code-server on port 8443"
}

# Output firewall rules
output "firewall_rules" {
  value = {
    ssh         = google_compute_firewall.allow_ssh.name
    https       = google_compute_firewall.allow_https.name
    code_server = google_compute_firewall.allow_code_server.name
  }
  description = "Created firewall rules"
}
