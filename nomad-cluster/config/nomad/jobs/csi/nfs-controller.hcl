job "plugin-nfs-controller" {
  datacenters = ["homelab"]
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
      }
      csi_plugin {
        id             = "nfsofficial"
        type           = "controller"
        mount_dir      = "/csi"
        health_timeout = "5m"
      }
      resources {
        memory = 32
        cpu    = 100
      }
    }
  }
}
