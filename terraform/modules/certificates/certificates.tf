// nomad CA
resource "tls_private_key" "cert-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "cert-ca" {
  is_ca_certificate     = true
  validity_period_hours = 87600

  #key_algorithm   = tls_private_key.cert-ca.algorithm
  private_key_pem = tls_private_key.cert-ca.private_key_pem

  subject {
    common_name  = "client.${var.datacenter}.${var.service}"
    organization = var.tls_organization
  }

  allowed_uses = [
    "client_auth", 
    "server_auth", 
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.service}-ca.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.service}-ca.pem",
    ]
  }

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/${var.service}/${var.service}-ca.pem"
  }
}


// nomad CLI
resource "tls_private_key" "cert-cli" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > /Users/alexgrieco/utilities/certs/${var.service}-client-cert-key.pem"
  }
}

resource "tls_cert_request" "cert-cli" {
  #key_algorithm   = tls_private_key.nomad-cli.algorithm
  private_key_pem = tls_private_key.cert-cli.private_key_pem

  ip_addresses = concat(
    ["127.0.0.1"], 
    var.server_ssh_hosts
  )

  dns_names = [
    "localhost",
    "cli.server.${var.datacenter}.nomad",
    "cli.${var.datacenter}.${var.service}",
  ]

  subject {
    common_name  = "cli.${var.datacenter}.${var.service}"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "cert-cli" {
  cert_request_pem = tls_cert_request.cert-cli.cert_request_pem

  ca_private_key_pem = tls_private_key.cert-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.cert-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth", 
    "server_auth", 
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/${var.service}-client-cert.pem"
  }
}

// nomad SERVER
resource "tls_private_key" "cert-server" {
  algorithm = "RSA"
  rsa_bits  = "2048"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "cert-server" {
  #key_algorithm   = tls_private_key.nomad-server.algorithm
  private_key_pem = tls_private_key.cert-server.private_key_pem

  ip_addresses = concat(
    ["127.0.0.1"],
    var.server_ssh_hosts
  )

  dns_names = [
    "localhost",
    "server.${var.datacenter}.${var.service}",
  ]

  subject {
    common_name  = "*.server.${var.datacenter}.${var.service}"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "cert-server" {
  cert_request_pem = tls_cert_request.cert-server.cert_request_pem

  #ca_key_algorithm   = tls_private_key.cert-ca.algorithm
  ca_private_key_pem = tls_private_key.cert-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.cert-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth", 
    "server_auth", 
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.server_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-server-global.pem",
    ]
  }
}

// nomad CLIENT
resource "tls_private_key" "cert-client" {
  algorithm = "RSA"
  rsa_bits  = "2048"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.private_key_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global-key.pem",
    ]
  }
}

resource "tls_cert_request" "cert-client" {
  #key_algorithm   = tls_private_key.cert-client.algorithm
  private_key_pem = tls_private_key.cert-client.private_key_pem

  ip_addresses = concat(
    ["127.0.0.1"], 
    var.client_ssh_hosts
  )

  dns_names = [
    "localhost",
    "client.${var.datacenter}.${var.service}",
  ]

  subject {
    common_name  = "*.client.${var.datacenter}.${var.service}"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "cert-client" {
  cert_request_pem = tls_cert_request.cert-client.cert_request_pem

  #ca_key_algorithm   = tls_private_key.cert-ca.algorithm
  ca_private_key_pem = tls_private_key.cert-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.cert-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth", 
    "server_auth", 
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[0]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[1]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.client_ssh_hosts[2]
      user        = "alex"
      private_key = var.private_key_file_content
      port        = "22"
    }
    inline = [
      "sudo mkdir -p /etc/certs/${var.service}/",
      "sudo chown -R alex:alex /etc/certs/",
      "echo '${self.cert_pem}' > /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
      "sudo chmod 0644 /etc/certs/${var.service}/${var.datacenter}-client-global.pem",
    ]
  }
}
