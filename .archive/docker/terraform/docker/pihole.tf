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


resource "remote_file" "cname_config" {
  conn {
    host        = var.vm_ip
    port        = 22
    user        = "alex"
    sudo        = true
    private_key = data.local_file.private_key.content
  }
  path        = "/etc-dnsmasq.d/05-pihole-custom-cname.conf"
  content     = <<-EOT
    %{for s in local.services~}
    cname=${s}.${var.local_domain},${var.docker_server_name}.${var.local_domain}
    %{endfor}
  EOT
  permissions = "0644"
}

resource "remote_file" "a_record_config" {
  conn {
    host        = var.vm_ip
    port        = 22
    user        = "alex"
    sudo        = true
    private_key = data.local_file.private_key.content
  }
  path        = "/etc-pihole/custom.list"
  content     = <<-EOT
    ${var.vm_ip} ${var.docker_server_name}.${var.local_domain}
  EOT
  permissions = "0644"
}

# Docker Config
resource "docker_image" "pihole" {
  name = "pihole/pihole:2024.07.0"
}

resource "docker_container" "pihole" {
  depends_on = [
    remote_file.cname_config,
    remote_file.a_record_config,
  ]

  name         = "pihole"
  image        = docker_image.pihole.image_id
  network_mode = "bridge"

  restart = "unless-stopped"

  # Using the tunnel secret
  env = toset([
    "TZ=America/Vancouver",
    "DNSMASQ_LISTENING=all",
    "WEBPASSWORD=${var.pihole_admin_password}",
    "PIHOLE_DNS_=10.13.13.1;1.1.1.1;1.0.0.1",
    "REV_SERVER=true",
    "REV_SERVER_TARGET=10.13.13.1",
    "REV_SERVER_CIDR=10.13.13.1/24",
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
