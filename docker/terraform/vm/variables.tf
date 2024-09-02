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

variable "vlan" {
  type    = number
  default = 2
}

variable "network" {
  type = string
}

# variable "private_key_file" {
#   type = string
# }
