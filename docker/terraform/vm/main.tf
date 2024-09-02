terraform {
  required_version = "~>1.3"

  cloud {
    organization = "grieco-homelab"

    workspaces {
      name = "docker-homelab-vm"
    }
  }

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.1"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret

  pm_tls_insecure = true
}
