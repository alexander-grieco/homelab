locals {
  services = [
    "traefik-dashboard",
    "gitlab",

    # External to Docker
    "pihole",
    "proxmox",
  ]
}
