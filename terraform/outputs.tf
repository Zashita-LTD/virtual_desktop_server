output "instance_name" {
  description = "Name of the created instance"
  value       = google_compute_instance.virtual_desktop.name
}

output "instance_id" {
  description = "ID of the created instance"
  value       = google_compute_instance.virtual_desktop.id
}

output "external_ip" {
  description = "External IP address of the instance"
  value       = google_compute_address.static_ip.address
}

output "code_server_url" {
  description = "URL to access code-server"
  value       = "https://${google_compute_address.static_ip.address}:8443"
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "gcloud compute ssh ${var.instance_name} --zone=${var.zone} --project=${var.project_id}"
}

output "service_account_email" {
  description = "Service account email for the instance"
  value       = google_service_account.instance_sa.email
}

output "persistent_disk_name" {
  description = "Name of the persistent disk (if enabled)"
  value       = var.enable_persistent_disk ? google_compute_disk.data_disk[0].name : "not-enabled"
}

output "installation_status_command" {
  description = "Command to check installation status"
  value       = "gcloud compute ssh ${var.instance_name} --zone=${var.zone} --project=${var.project_id} --command='tail -f /var/log/startup-script.log'"
}

output "next_steps" {
  description = "Next steps after deployment"
  value       = <<-EOT
  
  ✅ Deployment Complete!
  
  📍 Instance Information:
     Name: ${google_compute_instance.virtual_desktop.name}
     External IP: ${google_compute_address.static_ip.address}
     Zone: ${var.zone}
  
  🚀 Access code-server:
     URL: https://${google_compute_address.static_ip.address}:8443
     
  🔑 Get code-server password:
     ${format("gcloud compute ssh %s --zone=%s --project=%s --command='cat /home/%s/.config/code-server/config.yaml'", var.instance_name, var.zone, var.project_id, var.username)}
  
  📊 Check installation progress:
     ${format("gcloud compute ssh %s --zone=%s --project=%s --command='tail -f /var/log/startup-script.log'", var.instance_name, var.zone, var.project_id)}
  
  📚 Documentation:
     README: https://github.com/Zashita-LTD/virtual_desktop_server
     Quick Start: https://github.com/Zashita-LTD/virtual_desktop_server/blob/main/QUICKSTART.md
  
  ⏱️  Installation takes ~20-30 minutes. Monitor progress with the command above.
  EOT
}
