# SSH access - RESTRICTED to trusted IPs only
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  # Whitelist: VPN servers from Terraform_VPS_VPN project + admin IPs
  source_ranges = var.ssh_allowed_ips
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow SSH access from trusted IPs only"
}

# HTTPS for code-server - RESTRICTED to trusted IPs only
resource "google_compute_firewall" "allow_code_server" {
  name    = "${var.instance_name}-allow-code-server"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  
  # Whitelist: VPN servers from Terraform_VPS_VPN project + admin IPs
  source_ranges = var.code_server_allowed_ips
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow code-server HTTPS access from trusted IPs only"
}

# HTTPS (443) if using Nginx reverse proxy - RESTRICTED to trusted IPs only
resource "google_compute_firewall" "allow_https" {
  name    = "${var.instance_name}-allow-https"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  # Whitelist: VPN servers from Terraform_VPS_VPN project + admin IPs
  source_ranges = var.https_allowed_ips
  target_tags   = ["https-server", "code-server"]
  
  description = "Allow HTTPS access from trusted IPs only"
}

# ICMP for ping - Limited to infrastructure IPs for diagnostics
resource "google_compute_firewall" "allow_icmp" {
  name    = "${var.instance_name}-allow-icmp"
  network = "default"
  
  allow {
    protocol = "icmp"
  }
  
  # Whitelist: VPN servers + monitoring for diagnostics
  source_ranges = var.ssh_allowed_ips
  target_tags   = ["code-server", "virtual-desktop"]
  
  description = "Allow ICMP (ping) from trusted IPs for diagnostics"
}
