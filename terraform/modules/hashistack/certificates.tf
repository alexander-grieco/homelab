// nomad CA
resource "tls_private_key" "nomad-ca" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "nomad-ca" {
  is_ca_certificate     = true
  validity_period_hours = 87600

  #key_algorithm   = tls_private_key.nomad-ca.algorithm
  private_key_pem = tls_private_key.nomad-ca.private_key_pem

  subject {
    common_name  = "client.global.nomad"
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/nomad-ca.pem",
      "sudo chmod 0644 /etc/certs/nomad/nomad-ca.pem",
    ]
  }

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/nomad/nomad-ca.pem"
  }
}


// nomad CLI
resource "tls_private_key" "nomad-cli" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers,
    proxmox_vm_qemu.nomad-clients,
  ]
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > /Users/alexgrieco/utilities/certs/nomad-client-cert-key.pem"
  }
}

resource "tls_cert_request" "nomad-cli" {
  #key_algorithm   = tls_private_key.nomad-cli.algorithm
  private_key_pem = tls_private_key.nomad-cli.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-servers[0].ssh_host,
    proxmox_vm_qemu.nomad-servers[1].ssh_host,
    proxmox_vm_qemu.nomad-servers[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "cli.server.${var.datacenter}.nomad",
    "cli.global.nomad",
  ]

  subject {
    common_name  = "cli.global.nomad"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "nomad-cli" {
  cert_request_pem = tls_cert_request.nomad-cli.cert_request_pem

  #ca_key_algorithm   = tls_private_key.nomad-ca.algorithm
  ca_private_key_pem = tls_private_key.nomad-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.nomad-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/nomad-client-cert.pem"
  }
}

// nomad SERVER
resource "tls_private_key" "nomad-server" {
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "nomad-server" {
  #key_algorithm   = tls_private_key.nomad-server.algorithm
  private_key_pem = tls_private_key.nomad-server.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-servers[0].ssh_host,
    proxmox_vm_qemu.nomad-servers[1].ssh_host,
    proxmox_vm_qemu.nomad-servers[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "server.global.nomad",
  ]

  subject {
    common_name  = "*.server.global.nomad"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "nomad-server" {
  cert_request_pem = tls_cert_request.nomad-server.cert_request_pem

  #ca_key_algorithm   = tls_private_key.nomad-ca.algorithm
  ca_private_key_pem = tls_private_key.nomad-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.nomad-ca.cert_pem

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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-server-global.pem",
    ]
  }
}

// nomad CLIENT
resource "tls_private_key" "nomad-client" {
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "nomad-client" {
  #key_algorithm   = tls_private_key.nomad-client.algorithm
  private_key_pem = tls_private_key.nomad-client.private_key_pem

  ip_addresses = [
    "127.0.0.1",
    proxmox_vm_qemu.nomad-clients[0].ssh_host,
    proxmox_vm_qemu.nomad-clients[1].ssh_host,
    proxmox_vm_qemu.nomad-clients[2].ssh_host,
  ]

  dns_names = [
    "localhost",
    "client.global.nomad",
  ]

  subject {
    common_name  = "*.client.global.nomad"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "nomad-client" {
  cert_request_pem = tls_cert_request.nomad-client.cert_request_pem

  #ca_key_algorithm   = tls_private_key.nomad-ca.algorithm
  ca_private_key_pem = tls_private_key.nomad-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.nomad-ca.cert_pem

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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global.pem",
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
      "sudo mkdir -p /etc/certs/nomad/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/nomad/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/nomad/${var.datacenter}-client-global.pem",
    ]
  }
}
