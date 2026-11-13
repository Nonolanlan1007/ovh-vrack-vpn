data "ovh_cloud_instance_flavors" "catalog" {
  service_name = var.pc_project_id
  region       = var.pc_region
}

data "ovh_cloud_instance_images" "images" {
  service_name = var.pc_project_id
  region       = var.pc_region

  lifecycle {
    enabled = var.instance_image_id == null
  }
}

resource "tls_private_key" "key" {
  algorithm = "ED25519"

  lifecycle {
    enabled = var.instance_ssh_key_name == null
  }
}

data "tls_public_key" "key" {
  private_key_pem = tls_private_key.key.private_key_pem

  lifecycle {
    enabled = var.instance_ssh_key_name == null
  }
}

resource "random_id" "key_suffix" {
  byte_length = 2

  lifecycle {
    enabled = var.instance_ssh_key_name == null
  }
}

resource "ovh_cloud_ssh_key" "key" {
  service_name = var.pc_project_id
  name         = "vpn-endpoint-key-${random_id.key_suffix.hex}"
  public_key   = data.tls_public_key.key.public_key_openssh

  lifecycle {
    enabled = var.instance_ssh_key_name == null
  }
}

resource "ovh_cloud_instance" "instance" {
  service_name = var.pc_project_id
  region       = var.pc_region
  name         = var.instance_name
  flavor_id = one([
    for flavor in data.ovh_cloud_instance_flavors.catalog.flavors :
    flavor.id if flavor.name == var.instance_flavor
  ])
  image_id = var.instance_image_id == null ? one([
    for image in data.ovh_cloud_instance_images.images.images :
    image.id if image.name == "Debian 13"
  ]) : var.instance_image_id
  ssh_key_name = var.instance_ssh_key_name == null ? ovh_cloud_ssh_key.key.name : var.instance_ssh_key_name

  networks = [
    { auto_assign_public_ip = true },

    {
      network_id = var.private_network_id
      subnet_id  = var.private_network_subnet_id
      ip         = var.private_network_instance_ip
    },
  ]
}
