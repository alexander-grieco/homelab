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

variable "datacenter" {
  type = string
}

variable "private_key_file_content" {
  type      = string
  sensitive = true
}

#variable "domain" {
#  type = string
#}
#
#variable "tls_organization" {
#  type = string
#}
#
#variable "consul_version" {
#  type = string
#}
#
#variable "consul_control_plane_version" {
#  type = string
#}
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
