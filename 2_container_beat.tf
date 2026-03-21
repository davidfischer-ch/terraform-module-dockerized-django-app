resource "docker_container" "beat" {

  lifecycle {
    replace_triggered_by = [
      local_file.settings
    ]
  }

  image = var.image_id
  name  = "${var.identifier}-beat"

  entrypoint = concat([
    "celery",
    "--app", var.project_name,
    "beat",
    "--loglevel", upper(var.beat.log_level),
    "--schedule", "${local.container_workers_directory}/beat.db"
  ], var.beat.extra_options)

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  privileged = var.privileged

  dynamic "capabilities" {
    for_each = length(var.cap_add) + length(var.cap_drop) > 0 ? [1] : []
    content {
      add  = [for cap in var.cap_add : "CAP_${cap}"]
      drop = [for cap in var.cap_drop : "CAP_${cap}"]
    }
  }

  user = "${var.app_uid}:${var.app_gid}"

  # shm_size = 256 # MB

  env = []

  dynamic "host" {
    for_each = var.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  hostname = "${var.identifier}-beat"

  networks_advanced {
    name = var.network_id
  }

  network_mode = "bridge"

  # Config owner root:root (depending of how you called terraform apply)
  volumes {
    container_path = local.container_settings_path
    host_path      = local_file.settings.filename
    read_only      = true
  }

  # Workers owner <app>:<app>
  volumes {
    container_path = local.container_workers_directory
    host_path      = local.host_workers_directory
    read_only      = false
  }

  depends_on = [terraform_data.data_directories]
}
