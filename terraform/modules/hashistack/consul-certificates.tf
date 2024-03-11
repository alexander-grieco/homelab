// consul CA
resource "tls_private_key" "consul-ca" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "consul-ca" {
  is_ca_certificate     = true
  validity_period_hours = 87600

  #key_algorithm   = tls_private_key.consul-ca.algorithm
  private_key_pem = tls_private_key.consul-ca.private_key_pem

  subject {
    common_name  = "client.homelab.consul"
    organization = var.tls_organization
  }

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/consul-ca.pem",
      "sudo chmod 0644 /etc/certs/consul/consul-ca.pem",
    ]
  }

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/consul/consul-ca.pem"
  }
}


// consul CLI
resource "tls_private_key" "consul-cli" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > /Users/alexgrieco/utilities/certs/consul-client-cert-key.pem"
  }
}

resource "tls_cert_request" "consul-cli" {
  #key_algorithm   = tls_private_key.consul-cli.algorithm
  private_key_pem = tls_private_key.consul-cli.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-servers[0].ssh_host,
    proxmox_vm_qemu.nomad-servers[1].ssh_host,
    proxmox_vm_qemu.nomad-servers[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "cli.server.${var.datacenter}.consul",
    "cli.homelab.consul",
  ]

  subject {
    common_name  = "cli.homelab.consul"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "consul-cli" {
  cert_request_pem = tls_cert_request.consul-cli.cert_request_pem

  #ca_key_algorithm   = tls_private_key.consul-ca.algorithm
  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/consul-client-cert.pem"
  }
}

// consul SERVER
resource "tls_private_key" "consul-server" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "consul-server" {
  #key_algorithm   = tls_private_key.consul-server.algorithm
  private_key_pem = tls_private_key.consul-server.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-servers[0].ssh_host,
    proxmox_vm_qemu.nomad-servers[1].ssh_host,
    proxmox_vm_qemu.nomad-servers[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "server.homelab.consul",
  ]

  subject {
    common_name  = "*.server.homelab.consul"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "consul-server" {
  cert_request_pem = tls_cert_request.consul-server.cert_request_pem

  #ca_key_algorithm   = tls_private_key.consul-ca.algorithm
  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "server_auth",
    "client_auth",
  ]


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-servers[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-server-global.pem",
    ]
  }
}

// consul CLIENT
resource "tls_private_key" "consul-client" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/consul/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "consul-client" {
  #key_algorithm   = tls_private_key.consul-client.algorithm
  private_key_pem = tls_private_key.consul-client.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-clients[0].ssh_host,
    proxmox_vm_qemu.nomad-clients[1].ssh_host,
    proxmox_vm_qemu.nomad-clients[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "client.homelab.consul",
  ]

  subject {
    common_name  = "*.client.homelab.consul"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "consul-client" {
  cert_request_pem = tls_cert_request.consul-client.cert_request_pem

  #ca_key_algorithm   = tls_private_key.consul-ca.algorithm
  ca_private_key_pem = tls_private_key.consul-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.consul-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth",
    "client_auth",
  ]


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[0].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[1].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = proxmox_vm_qemu.nomad-clients[2].ssh_host
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/consul/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/consul/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/consul/${var.datacenter}-client-global.pem",
    ]
  }
}
