data "local_file" "private_key" {
  filename = pathexpand(var.private_key_file)
}

resource "proxmox_vm_qemu" "docker_server" {
  name        = "docker-server"
  desc        = "VM for Docker containers"
  vmid        = 100
  target_node = "pve"

  onboot = true

  clone = "ubuntu-server-jammy-docker"

  agent = 1 # Need this

  cpu     = "host"
  cores   = 4
  sockets = 1

  memory = 4096

  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = var.vlan
  }

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
      ide2 {
        cdrom {
          passthrough = false
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          backup    = true
          discard   = false
          format    = "raw"
          readonly  = false
          replicate = true
          size      = "128G"
          storage   = "local-lvm"
        }
      }
    }

  }

  scsihw = "virtio-scsi-pci"

  os_type = "cloud-init"

  ipconfig0 = "ip=${var.network}7/16,gw=${var.network}1"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  provisioner "remote-exec" {
    connection {
      host        = self.ssh_host
      user        = "alex"
      private_key = data.local_file.private_key.content
    }
    on_failure = continue

    inline = [<<-EOT
      sudo mkdir -p /opt/gitlab/config
      EOT
    ]
  }

  lifecycle {
    ignore_changes = [desc, tags, network, cicustom, qemu_os]
  }
}
