resource "docker_container" "web" {

  # TODO Handle multiple web nodes

  image = var.image_id
  name  = "${var.identifier}-web"

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  env = [
  ]

  hostname = "${var.identifier}-web"

  networks_advanced {
    name = var.network_id
  }

  ports {
    internal = 8000
    external = var.port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    container_path = "/home/app/src/${var.project_name}/.env"
    host_path      = local_file.settings.filename
    read_only      = true
  }

  volumes {
    container_path = local.container_media_directory
    host_path      = local.media_directory
    read_only      = false
  }

  volumes {
    container_path = local.container_static_directory
    host_path      = local.static_directory
    read_only      = false
  }
}
