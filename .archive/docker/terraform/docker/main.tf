terraform {
  required_version = "~>1.3"

  cloud {
    organization = "grieco-homelab"

    workspaces {
      name = "docker-homelab"
    }
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
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

provider "docker" {
  host     = "ssh://alex@${var.vm_ip}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-i", "~/.ssh/github_ed25519"]
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "local_file" "private_key" {
  filename = pathexpand(var.private_key_file)
}
