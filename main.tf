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

data "ovh_cloud_network_private_vrack_subnet" "subnet" {
  service_name = var.pc_project_id
  network_id   = var.private_network_id
  id           = var.private_network_subnet_id
}

resource "wireguard_asymmetric_key" "server" {
}

resource "wireguard_asymmetric_key" "client" {
}

resource "wireguard_preshared_key" "key" {
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

  networks = [
    { auto_assign_public_ip = true },

    {
      network_id = var.private_network_id
      subnet_id  = var.private_network_subnet_id
      ip         = var.private_network_instance_ip
    },
  ]

  user_data = base64encode(templatefile("cloud-init.yaml", {
    wg_port            = var.wireguard_port
    server_private_key = wireguard_asymmetric_key.server.private_key
    client_public_key  = wireguard_asymmetric_key.client.public_key
    preshared_key      = wireguard_preshared_key.key.key
    allowed_ips        = data.ovh_cloud_network_private_vrack_subnet.subnet.cidr
  }))
}

data "wireguard_config_document" "client" {
  private_key = wireguard_asymmetric_key.client.private_key
  addresses   = ["172.16.0.2/32"]

  peer {
    public_key    = wireguard_asymmetric_key.server.public_key
    preshared_key = wireguard_preshared_key.key.key
    allowed_ips   = ["172.16.0.0/24", data.ovh_cloud_network_private_vrack_subnet.subnet.cidr]
    endpoint = "${one([
      for network in ovh_cloud_instance.instance.current_state.networks :
      one([for address in network.addresses : address.ip if address.version == 4])
      if network.id == ""
    ])}:${var.wireguard_port}"
  }
}

output "client_wg_config" {
  value     = data.wireguard_config_document.client.conf
  sensitive = true
}