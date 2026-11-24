job "tetris" {
  datacenters = ["homelab"]

  group "games" {
    count = 5

    network {
      mode = "host" #default
      port "http" {
        to = 80
      }
    }

    task "tetris" {
      driver = "docker"

      config {
        image = "bsord/tetris"
        ports = ["http"]
      }

      resources {
        cpu    = 50
        memory = 50
      }
    }
  }
}
