module "certificates" {
  for_each = toset(["nomad", "consul", "vault"])

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]

  source = "../certificates"

  # ssh connection
  proxmox_api_url          = var.proxmox_api_url
  proxmox_token_id         = var.proxmox_token_id
  proxmox_token_secret     = var.proxmox_token_secret
  private_key_file_content = var.private_key_file_content
  server_ssh_hosts = proxmox_vm_qemu.nomad-servers[*].ssh_host
  client_ssh_hosts = proxmox_vm_qemu.nomad-clients[*].ssh_host

  # Cert info
  datacenter               = var.datacenter
  network                  = var.network
  vlan                     = var.vlan
  tls_organization         = var.tls_organization
  service          = each.key
}
