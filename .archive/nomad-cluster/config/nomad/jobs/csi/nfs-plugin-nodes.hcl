job "plugin-nfs-nodes" {
  datacenters = ["homelab"]
  type        = "system"
  group "nodes" {
    task "plugin" {
      driver = "docker"
      config {
        image = "registry.k8s.io/sig-storage/nfsplugin:v4.3.0"
        args = [
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=nfs.csi.k8s.io"
        ]
        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }
      csi_plugin {
        id             = "nfsofficial"
        type           = "node"
        mount_dir      = "/csi"
        health_timeout = "5m"
      }
      resources {
        memory = 10
      }
    }
  }
}
