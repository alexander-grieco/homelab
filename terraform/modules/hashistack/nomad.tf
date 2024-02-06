resource "random_id" "nomad-gossip-key" {
  byte_length = 32
}

resource "remote_file" "nomad_server" {
  depends_on = [
    proxmox_vm_qemu.proxy-node
  ]
  conn {
    host        = proxmox_vm_qemu.proxy-node.ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/server.hcl.tftpl", {
    server_ip = proxmox_vm_qemu.proxy-node.ssh_host
    gossip_key = random_id.nomad-gossip-key.b64_std,
    datacenter = var.datacenter,
    server_number = 1
    server1_ip = "10.2.0.10"
    server2_ip = "10.2.0.11"
    server3_ip = "10.2.0.12"
    #domain            = var.domain
  })
  path        = "/etc/nomad.d/server.hcl"
  permissions = "0640"
}

resource "remote_file" "nomad_service" {
  depends_on = [
    proxmox_vm_qemu.proxy-node,
    #tls_self_signed_cert.nomad-ca,
    #tls_private_key.nomad-server,
    #tls_locally_signed_cert.nomad-server,
  ]
  conn {
    host        = proxmox_vm_qemu.proxy-node.ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content     = file("${path.module}/templates/nomad/nomad.service.tftpl")
  path        = "/etc/systemd/system/nomad.service"
  permissions = "0640"
}

resource "null_resource" "start-nomad" {
  depends_on = [
    remote_file.nomad_server,
    remote_file.nomad_service,
  ]

  connection {
    type        = "ssh"
    host        = proxmox_vm_qemu.proxy-node.ssh_host
    user        = "root"
    private_key = var.private_key_file_content
    port        = "22"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable nomad",
      "sudo systemctl restart nomad",
    ]
  }
}
