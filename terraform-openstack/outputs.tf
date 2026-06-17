output "public_ip" {
  description = "Public floating IP of the bachelor service VM"
  value       = openstack_networking_floatingip_v2.bachelor_fip.address
}

output "service_url" {
  description = "URL to access the bachelor service"
  value       = "http://${openstack_networking_floatingip_v2.bachelor_fip.address}:8000"
}

output "health_url" {
  description = "URL to check the service health"
  value       = "http://${openstack_networking_floatingip_v2.bachelor_fip.address}:8000/health"
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ubuntu@${openstack_networking_floatingip_v2.bachelor_fip.address}"
}
