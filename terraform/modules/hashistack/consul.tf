#resource "random_id" "consul-gossip-key" {
#  byte_length = 32
#}
#
#resource "remote_file" "consul_server" {
#  depends_on = [
#    proxmox_vm_qemu.proxy-node
#  ]
#  conn {
#    host        = proxmox_vm_qemu.proxy-node.ssh_host
#    user        = "alex"
#    private_key = var.private_key_file_content
#    sudo        = true
#  }
#
#  content = templatefile("${path.module}/templates/server.hcl.tftpl", {
#    bind_addr         = proxmox_vm_qemu.proxy-node.ssh_host
#    consul_encryption = random_id.consul-gossip-key.b64_std,
#    consul_datacenter = var.datacenter,
#    domain            = var.domain
#  })
#  path        = "/etc/consul/server.hcl"
#  permissions = "0640"
#}
#
#resource "remote_file" "consul_service" {
#  depends_on = [
#    proxmox_vm_qemu.proxy-node,
#    tls_self_signed_cert.consul-ca,
#    tls_private_key.consul-server,
#    tls_locally_signed_cert.consul-server,
#  ]
#  conn {
#    host        = proxmox_vm_qemu.proxy-node.ssh_host
#    user        = "alex"
#    private_key = var.private_key_file_content
#    sudo        = true
#  }
#
#  content     = file("${path.module}/templates/consul.service.tftpl")
#  path        = "/etc/systemd/system/consul.service"
#  permissions = "0640"
#}
#
#resource "null_resource" "start-consul" {
#  depends_on = [
#    remote_file.consul_server,
#    remote_file.consul_service,
#  ]
#
#  connection {
#    type        = "ssh"
#    host        = proxmox_vm_qemu.proxy-node.ssh_host
#    user        = "root"
#    private_key = var.private_key_file_content
#    port        = "22"
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "sudo chown -R consul:consul /etc/consul/",
#      "sudo systemctl enable consul",
#      "sudo systemctl restart consul",
#    ]
#  }
#}
