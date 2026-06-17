output "instance_floating_ip" {
  description = "Public floating IP of the bachelor service VM"
  value       = openstack_networking_floatingip_v2.bachelor_fip.address
}

output "instance_id" {
  description = "ID of the created VM instance"
  value       = openstack_compute_instance_v2.bachelor_vm.id
}

output "service_url" {
  description = "URL to access the bachelor service"
  value       = "http://${openstack_networking_floatingip_v2.bachelor_fip.address}:5000"
}
