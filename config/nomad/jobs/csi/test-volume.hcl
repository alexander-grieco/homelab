job "test" {
  datacenters = ["homelab"]
  type        = "service"
  group "server" {
    count = 3
    volume "test" {
      type            = "csi"
      source          = "nfs-storage"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    task "server" {
      driver = "docker"
      config {
        image   = "busybox"
        command = "sh"
        args    = ["-c", "while true; do echo 'hello'; sleep 5; done"]
      }
      env {
        MOUNT_PATH = "${NOMAD_ALLOC_DIR}/test"
      }
      volume_mount {
        volume      = "test"
        destination = "${NOMAD_ALLOC_DIR}/test"
      }
    }
  }
}
