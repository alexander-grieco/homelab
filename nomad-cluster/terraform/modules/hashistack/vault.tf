################################################
# SERVER CONFIG
################################################
resource "remote_file" "vault_service" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.vault-servers,
    module.vault-certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.vault-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content     = file("${path.module}/templates/vault/vault.service.tftpl")
  path        = "/etc/systemd/system/vault.service"
  permissions = "0644"
}

resource "remote_file" "vault_server" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.vault-servers,
    remote_file.vault_service,
    module.vault-certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.vault-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/vault/vault.hcl.tftpl", {
    vault_node_id = "vault_server${count.index + 1}"
    datacenter    = var.datacenter
    server1_ip    = "${var.network}15"
    server2_ip    = "${var.network}16"
    server3_ip    = "${var.network}17"
    self_ip_addr  = "${var.network}${count.index + 15}"
  })
  path        = "/etc/vault.d/vault.hcl"
  permissions = "0644"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo systemctl enable vault",
      "sudo systemctl restart vault",
    ]
  }
}
