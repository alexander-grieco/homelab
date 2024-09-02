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

#variable "server_count" {
#  type    = number
#  default = 3
#}
#
#variable "client_count" {
#  type    = number
#  default = 3
#}

variable "network" {
  type = string
}

variable "vlan" {
  type = number
}

variable "tls_organization" {
  type = string
}

variable "service" {
  type = string
}

variable "server_ssh_hosts" {
  type = list(string)
}

variable "client_ssh_hosts" {
  type = list(string)
}
