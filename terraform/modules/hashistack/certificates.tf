#// CONSUL CA
#resource "tls_private_key" "consul-ca" {
#  algorithm = "RSA"
#  rsa_bits  = "2048"
#}
#
#resource "tls_self_signed_cert" "consul-ca" {
#  is_ca_certificate     = true
#  validity_period_hours = 87600
#
#  #key_algorithm   = tls_private_key.consul-ca.algorithm
#  private_key_pem = tls_private_key.consul-ca.private_key_pem
#
#  subject {
#    common_name  = "*.homelab.${var.domain}"
#    organization = var.tls_organization
#  }
#
#  allowed_uses = [
#    "cert_signing",
#    "digital_signature",
#    "key_encipherment",
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
#      "echo '${tls_self_signed_cert.consul-ca.cert_pem}' > /etc/consul/config/consul-agent-ca.pem",
#      "chmod 0600 /etc/consul/config/consul-agent-ca.pem",
#      "chown consul:consul /etc/consul/config/consul-agent-ca.pem"
#    ]
#  }
#
#  provisioner "local-exec" {
#    command = "echo '${tls_self_signed_cert.consul-ca.cert_pem}' > /etc/consul/config/consul-agent-ca.pem"
#  }
#}
#
#
#// CONSUL CLI
#resource "tls_private_key" "consul-cli" {
#  algorithm = "RSA"
#  rsa_bits  = "2048"
#
#  provisioner "local-exec" {
#    command = "echo '${tls_private_key.consul-cli.private_key_pem}' > /etc/consul/config/consul-client-cert-key.pem"
#  }
#}
#
#resource "tls_cert_request" "consul-cli" {
#  #key_algorithm   = tls_private_key.consul-cli.algorithm
#  private_key_pem = tls_private_key.consul-cli.private_key_pem
#
#  ip_addresses = [
#    "127.0.0.1",
#    proxmox_vm_qemu.proxy-node.ssh_host,
#  ]
#
#  dns_names = [
#    "localhost",
#    "cli.server.${var.datacenter}.${var.domain}",
#  ]
#
#  subject {
#    common_name  = "cli.homelab.${var.domain}"
#    organization = var.tls_organization
#  }
#}
#
#resource "tls_locally_signed_cert" "consul-cli" {
#  cert_request_pem = tls_cert_request.consul-cli.cert_request_pem
#
#  #ca_key_algorithm   = tls_private_key.consul-ca.algorithm
#  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
#  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem
#
#  validity_period_hours = 87600
#
#  allowed_uses = [
#    "digital_signature",
#    "key_encipherment",
#  ]
#
#  provisioner "local-exec" {
#    command = "echo '${tls_locally_signed_cert.consul-cli.cert_pem}' > /etc/consul/config/consul-client-cert.pem"
#  }
#}
#
#// CONSUL SERVER
#resource "tls_private_key" "consul-server" {
#  algorithm = "RSA"
#  rsa_bits  = "2048"
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
#      "echo '${tls_private_key.consul-server.private_key_pem}' > /etc/consul/config/${var.datacenter}-server-${var.domain}-0-key.pem",
#      "chmod 0600 /etc/consul/config/${var.datacenter}-server-${var.domain}-0-key.pem",
#      "chown consul:consul /etc/consul/config/${var.datacenter}-server-${var.domain}-0-key.pem"
#    ]
#  }
#}
#
#resource "tls_cert_request" "consul-server" {
#  #key_algorithm   = tls_private_key.consul-server.algorithm
#  private_key_pem = tls_private_key.consul-server.private_key_pem
#
#  ip_addresses = [
#    "127.0.0.1",
#    proxmox_vm_qemu.proxy-node.ssh_host,
#  ]
#
#  dns_names = [
#    "localhost",
#    "server.${var.datacenter}.${var.domain}",
#  ]
#
#  subject {
#    common_name  = "*.${var.datacenter}.${var.domain}"
#    organization = var.tls_organization
#  }
#}
#
#resource "tls_locally_signed_cert" "consul-server" {
#  cert_request_pem = tls_cert_request.consul-server.cert_request_pem
#
#  #ca_key_algorithm   = tls_private_key.consul-ca.algorithm
#  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
#  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem
#
#  validity_period_hours = 87600
#
#  allowed_uses = [
#    "server_auth",
#    "client_auth",
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
#      "echo '${tls_locally_signed_cert.consul-server.cert_pem}' > /etc/consul/config/${var.datacenter}-server-${var.domain}-0.pem",
#      "chmod 0600 /etc/consul/config/${var.datacenter}-server-${var.domain}-0.pem",
#      "chown consul:consul /etc/consul/config/${var.datacenter}-server-${var.domain}-0.pem"
#    ]
#  }
#}
#
#// CONSUL CLIENT
##resource "tls_private_key" "consul-client" {
##  algorithm = "RSA"
##  rsa_bits  = "2048"
##}
##
##resource "tls_cert_request" "consul-client" {
##  key_algorithm   = tls_private_key.consul-client.algorithm
##  private_key_pem = tls_private_key.consul-client.private_key_pem
##
##  ip_addresses = [
##    "127.0.0.1",
##  ]
##
##  dns_names = [
##    "localhost",
##    "client.dc1.consul",
##    "test.alexgrieco.io",
##  ]
##
##  subject {
##    common_name  = "client.dc1.consul"
##    organization = var.tls_organization
##  }
##}
##
##resource "tls_locally_signed_cert" "consul-client" {
##  cert_request_pem = tls_cert_request.consul-client.cert_request_pem
##
##  ca_key_algorithm   = tls_private_key.consul-ca.algorithm
##  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
##  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem
##
##  validity_period_hours = 87600
##
##  allowed_uses = [
##    "server_auth",
##    "client_auth",
##  ]
##}
