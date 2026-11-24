# Documentation: https://github.com/pi-hole/docker-pi-hole/blob/master/README.md

locals {
  gitlab_ports = {
    "ssh" = {
      protocol      = "tcp"
      external_port = 2424
      internal_port = 22
    }
    "http" = {
      protocol      = "tcp"
      external_port = 8080
      internal_port = 80
    }
    "https" = {
      protocol      = "tcp"
      external_port = 8443
      internal_port = 443
    }
  }
  gitlab_files = {
    "config/gitlab.rb" = "0644"
  }
  gitlab_labels = {
    "traefik.enable"                                                = "true"
    "traefik.http.routers.gitlab-https.rule"                        = "Host(`gitlab.local.alexgrieco.io`)"
    "traefik.http.routers.gitlab-https.entrypoints"                 = "https"
    "traefik.http.routers.gitlab-https.tls"                         = "true"
    "traefik.http.routers.gitlab-https.tls.certresolver"            = "cloudflare"
    "traefik.http.services.gitlab-service.loadbalancer.server.port" = "80"
  }
}

resource "remote_file" "gitlab_config" {
  for_each = local.gitlab_files

  conn {
    host        = var.vm_ip
    port        = 22
    user        = "alex"
    sudo        = true
    private_key = data.local_file.private_key.content
  }
  path        = "/opt/gitlab/${each.key}"
  content     = file("${path.module}/config/gitlab/${each.key}/")
  permissions = each.value
}

# Docker Config
resource "docker_image" "gitlab" {
  name = "gitlab/gitlab-ce:17.1.6-ce.0"
}

resource "docker_container" "gitlab" {
  depends_on = [
    remote_file.gitlab_config,
  ]

  name         = "gitlab"
  image        = docker_image.gitlab.image_id
  network_mode = "bridge"
  shm_size     = 256

  restart = "unless-stopped"

  dynamic "labels" {
    for_each = local.gitlab_labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "ports" {
    for_each = local.gitlab_ports
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
    container_path = "/etc/gitlab/"
    host_path      = "/opt/gitlab/config"
  }
  volumes {
    container_path = "/var/log/gitlab"
    host_path      = "/opt/gitlab/logs"
  }
  volumes {
    container_path = "/var/opt/gitlab"
    host_path      = "/opt/gitlab/data"
  }
}
