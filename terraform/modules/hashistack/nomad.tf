################################################
# SERVER CONFIG
################################################
resource "random_id" "nomad-gossip-key" {
  byte_length = 32
}

resource "remote_file" "nomad_service" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    tls_self_signed_cert.nomad-ca,
    tls_private_key.nomad-client,
    tls_locally_signed_cert.nomad-client,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/nomad.service.tftpl", {
    USER  = "nomad",
    GROUP = "nomad",
  })
  path        = "/etc/systemd/system/nomad.service"
  permissions = "0644"
}

resource "remote_file" "nomad_server" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    remote_file.nomad_service,
    tls_self_signed_cert.nomad-ca,
    tls_private_key.nomad-server,
    tls_locally_signed_cert.nomad-server,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/server.hcl.tftpl", {
    server_ip     = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    gossip_key    = random_id.nomad-gossip-key.b64_std,
    datacenter    = var.datacenter,
    server_number = count.index + 1,
    server1_ip    = "${var.network}10"
    server2_ip    = "${var.network}11"
    server3_ip    = "${var.network}12"
    consul_ssl    = true
    consul_addr   = "127.0.0.1:8501"
    consul_token  = random_uuid.consul_bootstrap_token.result
    #domain            = var.domain
  })
  path        = "/etc/nomad.d/server.hcl"
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
      "sudo systemctl enable nomad",
      "sudo systemctl restart nomad",
    ]
  }
}

################################################
# CLIENT CONFIG
################################################
resource "remote_file" "nomad_client_service" {
  count = var.client_count

  depends_on = [
    proxmox_vm_qemu.nomad-clients,
    tls_self_signed_cert.nomad-ca,
    tls_private_key.nomad-client,
    tls_locally_signed_cert.nomad-client,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/nomad.service.tftpl", {
    USER  = "root",
    GROUP = "root",
  })
  path        = "/etc/systemd/system/nomad.service"
  permissions = "0644"
}

resource "remote_file" "nomad_client" {
  count = var.client_count

  depends_on = [
    proxmox_vm_qemu.nomad-clients,
    remote_file.nomad_client_service,
    tls_self_signed_cert.nomad-ca,
    tls_private_key.nomad-client,
    tls_locally_signed_cert.nomad-client,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/client.hcl.tftpl", {
    client_ip     = proxmox_vm_qemu.nomad-clients[count.index].ssh_host
    datacenter    = var.datacenter,
    client_number = count.index + 1,
    server1_ip    = "${var.network}10"
    server2_ip    = "${var.network}11"
    server3_ip    = "${var.network}12"
    #domain            = var.domain
    consul_ssl   = true
    consul_addr  = "127.0.0.1:8501"
    consul_token = random_uuid.consul_bootstrap_token.result
  })
  path        = "/etc/nomad.d/client.hcl"
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
      "sudo systemctl enable nomad",
      "sudo systemctl restart nomad",
    ]
  }
}
