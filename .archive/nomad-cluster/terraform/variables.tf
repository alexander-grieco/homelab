variable "proxmox_api_url" {
  type = string
}

variable "proxmox_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

variable "private_key_file" {
  type = string
}

variable "datacenter" {
  type    = string
  default = "homelab"
}

variable "network" {
  type = string
}

variable "vlan" {
  type = number
}

#variable "domain" {
#  type    = string
#  default = "home.alexgrieco.io"
#}
#
variable "tls_organization" {
  type = string
}
#
#variable "acme" {
#  type = object({
#    email      = string
#    server     = string
#    domain     = string
#    cloudflare = map(string)
#  })
#  sensitive = true
#}
