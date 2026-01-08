# Terraform Outputs

output "project_info" {
  value = {
    project_id = var.project_id
    region     = var.region
    zone       = var.zone
  }
  description = "GCP project information"
}

output "instance_info" {
  value = {
    name         = google_compute_instance.virtual_desktop.name
    machine_type = google_compute_instance.virtual_desktop.machine_type
    zone         = google_compute_instance.virtual_desktop.zone
    external_ip  = google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip
    internal_ip  = google_compute_instance.virtual_desktop.network_interface[0].network_ip
  }
  description = "Instance details"
}

output "access_info" {
  value = {
    ssh_command      = "gcloud compute ssh ${google_compute_instance.virtual_desktop.name} --zone=${var.zone}"
    code_server_url  = "https://${google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip}:8443"
    monitoring_url   = "https://console.cloud.google.com/compute/instancesDetail/zones/${var.zone}/instances/${google_compute_instance.virtual_desktop.name}?project=${var.project_id}"
  }
  description = "Access information"
}

output "next_steps" {
  value = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════╗
    ║  Virtual Desktop Server Created Successfully!                   ║
    ╚════════════════════════════════════════════════════════════════╝
    
    SSH into the instance:
      ${join("\n      ", [
        "gcloud compute ssh ${google_compute_instance.virtual_desktop.name} --zone=${var.zone}",
        "OR",
        "ssh vik9541@${google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip}"
      ])}
    
    Run the installation script:
      cd ~
      git clone https://github.com/Zashita-LTD/virtual_desktop_server.git
      cd virtual_desktop_server
      sudo bash scripts/install/00-master-install.sh
    
    Access code-server:
      https://${google_compute_instance.virtual_desktop.network_interface[0].access_config[0].nat_ip}:8443
    
    View in GCP Console:
      https://console.cloud.google.com/compute/instancesDetail/zones/${var.zone}/instances/${google_compute_instance.virtual_desktop.name}?project=${var.project_id}
    
  EOT
  description = "Next steps after instance creation"
}
