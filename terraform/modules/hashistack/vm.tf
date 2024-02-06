resource "proxmox_vm_qemu" "proxy-node" {
  name        = "proxy-node"
  desc        = "proxy node"
  vmid        = 380
  target_node = "pve1"

  agent = 1 # Need this

  clone   = "ubuntu-server-jammy-proxy"
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 4096
  onboot  = true
  scsihw  = "virtio-scsi-single"

  network {
    bridge  = "vmbr0"
    model   = "virtio"
    macaddr = "10:00:00:00:00:01"
    tag     = 2
  }

  disk {
    storage = "local-zfs"
    type    = "scsi"
    size    = "64G"
  }

  os_type = "cloud-init"
  ciuser  = "alex"
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV+H0xdhLR1aYN5cbzHRHytek05hDXRb4vqlgAba4Dl github
  EOF
}
