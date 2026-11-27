# Tailscale side of the homelab: the policy file and one Service per app.
# Apply from this folder:  terraform apply
# Credentials (an OAuth client with Policy File: Write and Services: Write):
#   export TAILSCALE_OAUTH_CLIENT_ID=...
#   export TAILSCALE_OAUTH_CLIENT_SECRET=tskey-client-...

terraform {
  required_version = "1.17.2"

  cloud {

    organization = "grieco-homelab"

    workspaces {
      name = "tailscale-homelab"
    }
  }
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.30"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.29"
    }
  }
}

provider "tailscale" {}

