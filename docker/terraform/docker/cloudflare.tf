data "cloudflare_zone" "ag_io" {
  name = "alexgrieco.io"
}


resource "random_bytes" "tunnel_token" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = data.cloudflare_zone.ag_io.account_id
  name       = "homelab"
  secret     = random_bytes.tunnel_token.base64
  config_src = "cloudflare"
}

resource "cloudflare_record" "homelab_dns" {
  zone_id = data.cloudflare_zone.ag_io.id
  name    = "*.homelab"
  content = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}


# Docker Config
resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:2024.8.3-amd64"
}

resource "docker_container" "cloudflared" {
  depends_on = [
    cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel
  ]

  name         = "cloudflare_tunnel"
  image        = docker_image.cloudflared.image_id
  privileged   = true
  network_mode = "bridge"

  command = ["tunnel", "--no-autoupdate", "run", "homelab"]

  restart = "unless-stopped"

  # Using the tunnel secret
  env = toset(["TUNNEL_TOKEN=${cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.tunnel_token}"])


  # Networks
  networks_advanced {
    name = docker_network.frontend.name
  }
  networks_advanced {
    name = docker_network.homelab.name
  }
  networks_advanced {
    name = docker_network.backend.name
  }

  # Volumes
  volumes {
    container_path = "/etc/cloudflared"
    host_path      = "/etc/cloudflared"
    read_only      = true
  }
}
