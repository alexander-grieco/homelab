# Documentation: https://github.com/pi-hole/docker-pi-hole/blob/master/README.md

locals {
  pihole_ports = {
    "53_tcp" = {
      protocol      = "tcp"
      external_port = 53
      internal_port = 53
    }
    "53_udp" = {
      protocol      = "udp"
      external_port = 53
      internal_port = 53
    }
    "80_tcp" = {
      protocol      = "tcp"
      internal_port = 80
      external_port = 8001
    }
  }
}
# Docker Config
resource "docker_image" "pihole" {
  name = "pihole/pihole:2024.07.0"
}

resource "docker_container" "pihole" {
  name         = "pihole"
  image        = docker_image.pihole.image_id
  network_mode = "bridge"

  restart = "unless-stopped"

  # Using the tunnel secret
  env = toset([
    "TZ=America/Vancouver",
    "DNSMASQ_LISTENING=all",
    "WEBPASSWORD=${var.pihole_admin_password}",
    # "FTLCONF_LOCAL_IPV4=${var.vm_ip}",
    "PIHOLE_DNS_=10.13.13.1;1.1.1.1;1.0.0.1",
    "WEBTHEME=default-dark",
  ])

  dynamic "ports" {
    for_each = local.pihole_ports
    content {
      internal = ports.value.internal_port
      external = ports.value.external_port
      protocol = ports.value.protocol
    }
  }

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
  networks_advanced {
    name = "bridge"
  }

  # Volumes
  volumes {
    container_path = "/etc/pihole"
    host_path      = "/etc-pihole"
  }
  volumes {
    container_path = "/etc/dnsmasq.d"
    host_path      = "/etc-dnsmasq.d"
  }
}
