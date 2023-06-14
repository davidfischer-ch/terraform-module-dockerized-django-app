resource "docker_container" "workers" {

  for_each = var.workers

  lifecycle {
    replace_triggered_by = [
      local_file.settings
    ]
  }

  image = var.image_id
  name  = "${var.identifier}-worker-${each.key}"

  entrypoint = concat([
    "celery",
    "--app", var.project_name,
    "worker",
    "--hostname", each.value.name,
    "--loglevel", upper(each.value.log_level),
    "--queues", join(",", each.value.queues),
    "--statedb", "${local.container_workers_directory}/worker-${each.key}.db"
  ], each.value.extra_options)

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  env = [
  ]

  hostname = "${var.identifier}-worker-${each.key}"

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

  volumes {
    container_path = local.container_workers_directory
    host_path      = local.host_workers_directory
    read_only      = false
  }
}
