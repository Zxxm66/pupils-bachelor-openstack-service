variable "os_username" {
  description = "OpenStack username"
  type        = string
}

variable "os_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

variable "os_project_name" {
  description = "OpenStack project (tenant) name"
  type        = string
}

variable "os_auth_url" {
  description = "OpenStack Keystone auth URL"
  type        = string
  default     = "http://controller:5000/v3"
}

variable "os_region" {
  description = "OpenStack region"
  type        = string
  default     = "RegionOne"
}

variable "external_network_id" {
  description = "ID of the external (public) network for router gateway"
  type        = string
}

variable "floating_ip_pool" {
  description = "Name of the floating IP pool"
  type        = string
  default     = "public"
}

variable "image_name" {
  description = "Name of the OS image to use"
  type        = string
  default     = "Ubuntu-22.04"
}

variable "flavor_name" {
  description = "OpenStack flavor name"
  type        = string
  default     = "m1.small"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "docker_image" {
  description = "Docker image to run on the VM"
  type        = string
  default     = "Zxxm66/pupils-bachelor-openstack-service:latest"
}
