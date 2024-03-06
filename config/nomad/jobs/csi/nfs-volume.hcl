type        = "csi"
id          = "nfs-storage"
name        = "nfs-storage"
plugin_id   = "nfsofficial"
external_id = "nfs-storage"
capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}
context {
  server           = "10.13.13.3"
  share            = "/mnt/homelab/proxmox/storage"
  mountPermissions = "0"
}
mount_options {
  # fs_type = "nfs"
  mount_flags = ["intr", "vers=4", "_netdev", "nolock", "noatime"]
}
