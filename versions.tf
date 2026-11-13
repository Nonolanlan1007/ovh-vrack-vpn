terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.24"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4"
    }
  }
}