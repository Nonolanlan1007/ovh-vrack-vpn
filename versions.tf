terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.24"
    }
    wireguard = {
      source  = "ojford/wireguard"
      version = "~> 0.4"
    }
  }
}