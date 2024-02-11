resource "random_id" "nomad-gossip-key" {
  byte_length = 32
}

resource "remote_file" "nomad_server" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content = templatefile("${path.module}/templates/nomad/server.hcl.tftpl", {
    server_ip = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    gossip_key = random_id.nomad-gossip-key.b64_std,
    datacenter = var.datacenter,
    server_number = count.index + 1,
    server1_ip = "${var.network}0"
    server2_ip = "${var.network}1"
    server3_ip = "${var.network}2"
    #domain            = var.domain
  })
  path        = "/etc/nomad.d/server.hcl"
  permissions = "0644"
}

resource "remote_file" "nomad_service" {
  count = var.server_count

  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    #tls_self_signed_cert.nomad-ca,
    #tls_private_key.nomad-server,
    #tls_locally_signed_cert.nomad-server,
  ]
  conn {
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    sudo        = true
  }

  content     = file("${path.module}/templates/nomad/nomad.service.tftpl")
  path        = "/etc/systemd/system/nomad.service"
  permissions = "0644"
}

resource "null_resource" "start-nomad" {
  count = var.server_count

  depends_on = [
    remote_file.nomad_server,
    remote_file.nomad_service,
  ]

  connection {
    type        = "ssh"
    host        = proxmox_vm_qemu.nomad-servers[count.index].ssh_host
    user        = "alex"
    private_key = var.private_key_file_content
    port        = "22"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm /etc/nomad.d/nomad.hcl",
      "sudo systemctl enable nomad",
      "sudo systemctl restart nomad",
    ]
  }
}
