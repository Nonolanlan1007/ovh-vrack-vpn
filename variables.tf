variable "pc_project_id" {
  type        = string
  description = "The ID of your OVH Public Cloud Project"
  nullable    = false
}

variable "pc_region" {
  type        = string
  description = "The region where you want to deploy the VPN endpoint to"
  default     = "GRA9"
}

variable "instance_name" {
  type        = string
  description = "The name of the instance"
  default     = "vpn-endpoint"
}

variable "instance_image_id" {
  type        = string
  description = "The ID of the instance's image"
  default     = null
  nullable    = true
}

variable "instance_flavor" {
  type        = string
  description = "The instance flavor name"
  default     = "d2-2"
}

variable "instance_ssh_key_name" {
  type        = string
  description = "The name of an existing SSH Key name"
  default     = null
  nullable    = true
}

variable "private_network_id" {
  type        = string
  description = "The ID of the OpenStack network you want to connect to"
  nullable    = false
}

variable "private_network_subnet_id" {
  type        = string
  description = "The ID of the subnet the instance should connect to"
  nullable    = false
}

variable "private_network_instance_ip" {
  type        = string
  description = "The IP of the instance inside the private subnet"
  default     = null
  nullable    = true
}
