terraform {
  required_version = ">= 1.0.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
}

provider "openstack" {
  user_name   = var.os_username
  tenant_name = var.os_project_name
  password    = var.os_password
  auth_url    = var.os_auth_url
  region      = var.os_region
}

# Security group
resource "openstack_networking_secgroup_v2" "bachelor_sg" {
  name        = "bachelor-service-sg"
  description = "Security group for bachelor service"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bachelor_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "app_port" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bachelor_sg.id
}

# Network
resource "openstack_networking_network_v2" "bachelor_net" {
  name           = "bachelor-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "bachelor_subnet" {
  name       = "bachelor-subnet"
  network_id = openstack_networking_network_v2.bachelor_net.id
  cidr       = "192.168.100.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "bachelor_router" {
  name                = "bachelor-router"
  admin_state_up      = true
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "bachelor_ri" {
  router_id = openstack_networking_router_v2.bachelor_router.id
  subnet_id = openstack_networking_subnet_v2.bachelor_subnet.id
}

# Keypair
resource "openstack_compute_keypair_v2" "bachelor_key" {
  name       = "bachelor-keypair"
  public_key = file(var.public_key_path)
}

# Instance
resource "openstack_compute_instance_v2" "bachelor_vm" {
  name            = "bachelor-service-vm"
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.bachelor_key.name
  security_groups = [openstack_networking_secgroup_v2.bachelor_sg.name]

  network {
    uuid = openstack_networking_network_v2.bachelor_net.id
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker
    docker run -d -p 5000:5000 ${var.docker_image}
  EOF
}

# Floating IP
resource "openstack_networking_floatingip_v2" "bachelor_fip" {
  pool = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "bachelor_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.bachelor_fip.address
  instance_id = openstack_compute_instance_v2.bachelor_vm.id
}
