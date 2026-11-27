# Wildcard DNS: *.<subdomain>.<zone> -> svc:caddy's Tailscale address. Only
# reachable from the tailnet; Caddy routes <name>.<subdomain>.<zone> to svc:<name>.
# Not at the zone root: Cloudflare's Universal SSL owns _acme-challenge.<zone>,
# which would block Caddy's DNS challenge for *.<zone>.

variable "zone" {
  description = "Cloudflare zone (registered domain)."
  type        = string
  default     = "grieco.tech"
}

variable "subdomain" {
  description = "Services live at <name>.<subdomain>.<zone>."
  type        = string
  default     = "hl"
}

provider "cloudflare" {} # token from CLOUDFLARE_API_TOKEN

data "cloudflare_zone" "zone" {
  filter = {
    name = var.zone
  }
}

locals {
  # svc:caddy has one IPv4 and one IPv6 address; the A record needs the IPv4.
  caddy_ipv4 = one([for a in tailscale_service.homelab["caddy"].addrs : a if !strcontains(a, ":")])
}

resource "cloudflare_dns_record" "homelab_wildcard" {
  zone_id = data.cloudflare_zone.zone.id
  name    = "*.${var.subdomain}.${var.zone}"
  type    = "A"
  content = local.caddy_ipv4
  ttl     = 1     # automatic
  proxied = false # Cloudflare can't reach tailnet addresses
  comment = "Homelab: tailnet-only, managed by Terraform"
}
