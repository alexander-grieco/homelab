################################################
# SERVER CONFIG
################################################
resource "random_id" "consul-gossip-key" {
  byte_length = 32
}

resource "random_uuid" "consul_bootstrap_token" {}

resource "remote_file" "consul_service" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    module.certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/consul/consul.service.tftpl", {
    USER  = "consul",
    GROUP = "consul",
    TYPE  = "server",
  })
  path        = "/etc/systemd/system/consul.service"
  permissions = "0644"
}

resource "remote_file" "consul_server" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    remote_file.consul_service,
    module.certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/consul/server.hcl.tftpl", {
    bind_addr              = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    consul_encryption      = random_id.consul-gossip-key.b64_std,
    consul_datacenter      = var.datacenter,
    server_number          = count.index + 1,
    server1_ip             = "${var.network}10"
    server2_ip             = "${var.network}11"
    server3_ip             = "${var.network}12"
    consul_bootstrap_token = random_uuid.consul_bootstrap_token.result
  })
  path        = "/etc/consul.d/server.hcl"
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
      "sudo systemctl enable consul",
      "sudo systemctl restart consul",
    ]
  }
}

################################################
# CLIENT CONFIG
################################################
resource "remote_file" "consul_client_service" {
  count = var.client_count

  depends_on = [
    proxmox_vm_qemu.nomad-clients,
    module.certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/consul/consul.service.tftpl", {
    USER  = "root",
    GROUP = "root",
    TYPE  = "client",
  })
  path        = "/etc/systemd/system/consul.service"
  permissions = "0644"
}

resource "remote_file" "consul_client" {
  count = var.client_count

  depends_on = [
    proxmox_vm_qemu.nomad-clients,
    remote_file.consul_client_service,
    module.certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/consul/client.hcl.tftpl", {
    bind_addr              = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    consul_datacenter      = var.datacenter,
    server1_ip             = "${var.network}10"
    server2_ip             = "${var.network}11"
    server3_ip             = "${var.network}12"
    consul_encryption_key  = random_id.consul-gossip-key.b64_std
    consul_bootstrap_token = random_uuid.consul_bootstrap_token.result
  })
  path        = "/etc/consul.d/client.hcl"
  permissions = "0644"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo systemctl enable consul",
      "sudo systemctl restart consul",
    ]
  }
}

################################################
# VAULT CLIENT CONFIG
################################################
resource "remote_file" "consul_client_vault_service" {
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

  content = templatefile("${path.module}/templates/consul/consul.service.tftpl", {
    USER  = "root",
    GROUP = "root",
    TYPE  = "client",
  })
  path        = "/etc/systemd/system/consul.service"
  permissions = "0644"
}

resource "remote_file" "consul_vault_client" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.vault-servers,
    remote_file.consul_client_vault_service,
    module.vault-certificates,
  ]
  conn {
    host        = proxmox_vm_qemu.vault-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/consul/client.hcl.tftpl", {
    bind_addr              = proxmox_vm_qemu.vault-servers[count.index].ssh_host
    consul_datacenter      = var.datacenter,
    server1_ip             = "${var.network}10"
    server2_ip             = "${var.network}11"
    server3_ip             = "${var.network}12"
    consul_encryption_key  = random_id.consul-gossip-key.b64_std
    consul_bootstrap_token = random_uuid.consul_bootstrap_token.result
  })
  path        = "/etc/consul.d/client.hcl"
  permissions = "0644"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.vault-servers[count.index].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo systemctl enable consul",
      "sudo systemctl restart consul",
    ]
  }
}
