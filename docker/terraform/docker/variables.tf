variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}
variable "traefik_dashboard_credentials" {
  description = "Traefik Dashboard Credentials"
  type        = string
}

variable "pihole_admin_password" {
  description = "Pihold admin password"
  type        = string
  sensitive   = true
}

variable "private_key_file" {
  description = "Path to the private key file"
  type        = string
}

variable "vm_ip" {
  description = "IP of the Docker VM"
  type        = string
  default     = "10.2.0.7"
}
