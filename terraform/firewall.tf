# SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]  # Recommended to restrict to your IP
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow SSH access"
}

# HTTPS for code-server
resource "google_compute_firewall" "allow_code_server" {
  name    = "${var.instance_name}-allow-code-server"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow code-server HTTPS access"
}

# HTTPS (443) if using Nginx reverse proxy
resource "google_compute_firewall" "allow_https" {
  name    = "${var.instance_name}-allow-https"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server", "code-server"]
  
  description = "Allow HTTPS access"
}

# ICMP for ping
resource "google_compute_firewall" "allow_icmp" {
  name    = "${var.instance_name}-allow-icmp"
  network = "default"
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow ICMP (ping)"
}
