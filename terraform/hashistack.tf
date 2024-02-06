module "hashistack" {
  source = "./modules/hashistack"

  proxmox_api_url              = var.proxmox_api_url
  proxmox_token_id             = var.proxmox_token_id
  proxmox_token_secret         = var.proxmox_token_secret
  datacenter                   = var.datacenter
  private_key_file_content     = data.local_sensitive_file.private_key.content
  #consul_version               = "1.14.4"
  #consul_control_plane_version = "1.0.4"
  #acme                         = var.acme
  #tls_organization             = var.tls_organization
  #domain                       = var.domain
}