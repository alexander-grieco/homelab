resource "proxmox_vm_qemu" "nomad-servers" {
  count = var.server_count

  name        = "nomad-server${count.index + 1}"
  desc        = "Nomad Server ${count.index + 1}"
  vmid        = parseint("10${count.index}", 10)
  target_node = "pve"

  onboot = true

  clone = "ubuntu-server-jammy-nomad"

  agent = 1 # Need this

  cpu     = "host"
  cores   = 2
  sockets = 1

  memory = 4096

  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = var.vlan
  }

  os_type = "cloud-init"

  ipconfig0 = "gw=${var.network}1,ip=${var.network}1${count.index}/32"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  lifecycle {
    ignore_changes = [desc, tags, network, disk, cicustom, qemu_os]
  }
}

resource "proxmox_vm_qemu" "nomad-clients" {
  depends_on = [
    proxmox_vm_qemu.nomad-servers
  ]
  count = var.client_count

  name        = "nomad-client${count.index + 1}"
  desc        = "Nomad Client ${count.index + 1}"
  vmid        = parseint("11${count.index}", 10)
  target_node = "pve"

  agent      = 1 # Need this
  full_clone = true
  clone      = "ubuntu-server-jammy-nomad"
  cpu        = "host"
  cores      = 2
  sockets    = 1
  memory     = 4096
  onboot     = true
  os_type    = "cloud-init"
  qemu_os    = "l26"
  scsihw     = "virtio-scsi-single"

  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = var.vlan
  }

  ipconfig0 = "gw=${var.network}1,ip=${var.network}2${count.index}/32"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  lifecycle {
    ignore_changes = [desc, tags, network, disk, cicustom, qemu_os]
  }
}

resource "proxmox_vm_qemu" "vault-servers" {
  count = var.server_count

  name        = "vault-server${count.index + 1}"
  desc        = "Vault Server ${count.index + 1}"
  vmid        = parseint("10${count.index}", 10)
  target_node = "pve"

  onboot = true

  clone = "ubuntu-server-jammy-nomad"

  agent = 1 # Need this

  cpu     = "host"
  cores   = 2
  sockets = 1

  memory = 4096

  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = var.vlan
  }

  os_type = "cloud-init"

  ipconfig0 = "gw=${var.network}1,ip=${var.network}1${count.index + 5}/32"

  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF

  lifecycle {
    ignore_changes = [desc, tags, network, disk, cicustom, qemu_os]
  }
}
