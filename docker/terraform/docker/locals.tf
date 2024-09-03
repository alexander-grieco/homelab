locals {
  services = [
    "traefik-dashboard",

    # External to Docker
    "pihole",
    "proxmox",
  ]
}
