variable "domain" {
  description = "Domain whose subdomains map to homelab Services."
  type        = string
  default     = "grieco.tech"
}

provider "cloudflare" {}

data "cloudflare_zone" "domain" {
  filter = {
    name = var.domain
  }
}

locals {
  caddy_ipv4 = one([for a in tailscale_service.homelab["caddy"].addrs : a if !strcontains(a, ":")])
}

resource "cloudflare_dns_record" "homelab_wildcard" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "*.${var.domain}"
  type    = "A"
  content = local.caddy_ipv4
  ttl     = 1
  proxied = false
  comment = "Homelab: tailnet-only, managed by Terraform"
}
