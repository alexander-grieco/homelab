// CA
resource "tls_private_key" "cert-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "cert-ca" {
  is_ca_certificate     = true
  validity_period_hours = 87600

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
      host        = length(var.client_ssh_hosts) == 0 ? "" : var.client_ssh_hosts[0]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = length(var.client_ssh_hosts) == 0 ? "" : var.client_ssh_hosts[1]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = length(var.client_ssh_hosts) == 0 ? "" : var.client_ssh_hosts[2]
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
    on_failure = continue
  }

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > /Users/alexgrieco/utilities/certs/${var.service}/${var.service}-ca.pem"
  }
}


// CLI
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

// SERVER
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

// CLIENT
resource "tls_private_key" "cert-client" {
  count = length(var.client_ssh_hosts) == 0 ? 0 : 1

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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[3]) == false ? "" : var.client_ssh_hosts[3]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[4]) == false ? "" : var.client_ssh_hosts[4]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[5]) == false ? "" : var.client_ssh_hosts[5]
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
    on_failure = continue
  }
}

resource "tls_cert_request" "cert-client" {
  count = length(var.client_ssh_hosts) == 0 ? 0 : 1

  private_key_pem = tls_private_key.cert-client[0].private_key_pem

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
  count = length(var.client_ssh_hosts) == 0 ? 0 : 1

  cert_request_pem = tls_cert_request.cert-client[0].cert_request_pem

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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[3]) == false ? "" : var.client_ssh_hosts[3]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[4]) == false ? "" : var.client_ssh_hosts[4]
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
    on_failure = continue
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = can(var.client_ssh_hosts[5]) == false ? "" : var.client_ssh_hosts[5]
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
    on_failure = continue
  }
}
