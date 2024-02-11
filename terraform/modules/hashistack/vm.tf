resource "proxmox_vm_qemu" "nomad-servers" {
  count = var.server_count

  name        = "nomad-server${count.index + 1}"
  vmid        = parseint("10${count.index}", 10)
  target_node = "pve"

  agent = 1 # Need this

  clone   = "ubuntu-server-jammy-nomad"
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 4096
  onboot  = true
  scsihw  = "virtio-scsi-single"

  network {
    bridge  = "vmbr0"
    model   = "virtio"
    tag     = var.vlan
  }

  disk {
    storage = "storage"
    type    = "scsi"
    size    = "64G"
  }

  ipconfig0 = "gw=${var.network},ip=${var.network}${count.index}/32"

  os_type = "cloud-init"
  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF
}
