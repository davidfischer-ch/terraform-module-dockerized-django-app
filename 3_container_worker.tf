resource "docker_container" "celery_worker" {

  # TODO Handle multiple workers with multiple queues

  image = var.image_id
  name  = "${var.identifier}-celery-worker"

  entrypoint = ["/usr/bin/bash", "-c"]
  command    = ["sleep infinity"]

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  env = [
  ]

  hostname = "${var.identifier}-celery-worker"

  networks_advanced {
    name = var.network_id
  }

  volumes {
    container_path = local.container_settings_path
    host_path      = local_file.settings.filename
    read_only      = true
  }

  volumes {
    container_path = local.container_media_directory
    host_path      = local.host_media_directory
    read_only      = false
  }

  volumes {
    container_path = local.container_static_directory
    host_path      = local.host_static_directory
    read_only      = true
  }
}
