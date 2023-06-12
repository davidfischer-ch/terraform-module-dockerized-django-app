resource "docker_container" "celery_beat" {

  image = var.image_id
  name  = "${var.identifier}-celery-beat"

  entrypoint = ["/usr/bin/bash", "-c"]
  command    = ["sleep infinity"]

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  env = [
  ]

  hostname = "${var.identifier}-celery-beat"

  networks_advanced {
    name = var.network_id
  }

  volumes {
    container_path = "/home/app/src/${var.project_name}/.env"
    host_path      = local_file.settings.filename
    read_only      = true
  }

  volumes {
    container_path = local.container_media_directory
    host_path      = local.media_directory
    read_only      = true
  }

  volumes {
    container_path = local.container_static_directory
    host_path      = local.static_directory
    read_only      = true
  }
}
