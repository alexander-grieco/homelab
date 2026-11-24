resource "docker_network" "frontend" {
  name            = "frontend"
  check_duplicate = true
  driver          = "bridge"
}

resource "docker_network" "backend" {
  name            = "backend"
  check_duplicate = true
  driver          = "bridge"
}


resource "docker_network" "homelab" {
  name            = "homelab"
  check_duplicate = true
  driver          = "bridge"
}

