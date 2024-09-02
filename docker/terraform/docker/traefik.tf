resource "docker_image" "traefik" {
  name = "traefik:v3.1.2"
}

locals {
  traefik_files = {
    "traefik.yml" = "0644"
    "config.yml"  = "0644"
  }
  traefik_ports = toset([
    "80",
    "443",
  ])
  traefik_labels = {
    "traefik.enable"                                                                    = "true"
    "traefik.http.routers.traefik.entrypoints"                                          = "http"
    "traefik.http.routers.traefik.rule"                                                 = "Host(`traefik-dashboard.local.alexgrieco.io`)"
    "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme"             = "https"
    "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto" = "https"
    "traefik.http.routers.traefik.middlewares"                                          = "traefik-https-redirect"
    "traefik.http.routers.traefik-secure.entrypoints"                                   = "https"
    "traefik.http.routers.traefik-secure.rule"                                          = "Host(`traefik-dashboard.local.alexgrieco.io`)"
    "traefik.http.routers.traefik-secure.middlewares"                                   = "traefik-auth"
    "traefik.http.routers.traefik-secure.tls"                                           = "true"
    "traefik.http.routers.traefik-secure.tls.certresolver"                              = "cloudflare"
    "traefik.http.routers.traefik-secure.tls.domains[0].main"                           = "local.alexgrieco.io"
    "traefik.http.routers.traefik-secure.tls.domains[0].sans"                           = "*.local.alexgrieco.io"
    "traefik.http.routers.traefik-secure.service"                                       = "api@internal"
  }
  secure_labels = {
    "traefik.http.middlewares.traefik-auth.basicauth.users" = var.traefik_dashboard_credentials
  }
}

resource "remote_file" "traefik_config" {
  for_each = local.traefik_files

  conn {
    host        = var.vm_ip
    port        = 22
    user        = "alex"
    sudo        = true
    private_key = data.local_file.private_key.content
  }
  path        = "/tmp/${each.key}"
  content     = file("${path.module}/config/traefik/${each.key}")
  permissions = each.value
}

resource "remote_file" "acme_config" {
  conn {
    host        = var.vm_ip
    port        = 22
    user        = "alex"
    sudo        = true
    private_key = data.local_file.private_key.content
  }
  path        = "/usr/local/acme.json"
  content     = file("${path.module}/config/traefik/acme.json")
  permissions = "0600"

  lifecycle {
    ignore_changes = [content]
  }
}


resource "docker_container" "traefik" {
  name         = "traefik"
  image        = docker_image.traefik.image_id
  privileged   = true
  network_mode = "bridge"
  restart      = "unless-stopped"

  security_opts = [
    "no-new-privileges:true",
    "label=disable",
  ]

  # Using cloudflare credentials
  env = toset([
    "CF_DNS_API_TOKEN=${var.cloudflare_api_token}",
  ])


  networks_advanced {
    name = docker_network.homelab.name
  }

  dynamic "ports" {
    for_each = local.traefik_ports
    content {
      internal = ports.key
      external = ports.key
    }
  }

  dynamic "labels" {
    for_each = local.traefik_labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  dynamic "labels" {
    for_each = local.secure_labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  # Volumes
  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    container_path = "/traefik.yml"
    host_path      = "/tmp/traefik.yml"
    read_only      = true
  }
  volumes {
    container_path = "/acme.json"
    host_path      = "/usr/local/acme.json"
  }
  # volumes {
  #   container_path = "/config.yml"
  #   host_path      = "/tmp/config.yml"
  #   read_only      = true
  # }

}


