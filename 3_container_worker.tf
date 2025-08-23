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

  env = []

  dynamic "host" {
    for_each = var.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  hostname = "${var.identifier}-worker-${each.key}"

  networks_advanced {
    name = var.network_id
  }

  network_mode = "bridge"

  # Config owner root:root
  volumes {
    container_path = local.container_settings_path
    host_path      = local_file.settings.filename
    read_only      = true
  }

  # Media owner <app>:<app>
  volumes {
    container_path = local.container_media_directory
    host_path      = local.host_media_directory
    read_only      = false
  }

  # Protected owner root:root
  volumes {
    container_path = local.container_protected_directory
    host_path      = local.host_protected_directory
    read_only      = false
  }

  # Static owner <app>:<app>
  volumes {
    container_path = local.container_static_directory
    host_path      = local.host_static_directory
    read_only      = true
  }

  # Workers owner <app>:<app>
  volumes {
    container_path = local.container_workers_directory
    host_path      = local.host_workers_directory
    read_only      = false
  }

  provisioner "local-exec" {
    command = <<EOT
      chown "${var.data_owner}" "${local.host_media_directory}"
      chown "${var.data_owner}" "${local.host_static_directory}"
      chown "${var.data_owner}" "${local.host_workers_directory}"
    EOT
  }
}
