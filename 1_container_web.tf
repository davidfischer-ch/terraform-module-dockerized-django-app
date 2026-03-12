resource "docker_container" "web" {

  # TODO Handle multiple web nodes

  lifecycle {
    replace_triggered_by = [
      local_file.settings
    ]
  }

  image = var.image_id
  name  = "${var.identifier}-web"

  entrypoint = [
    "uvicorn",
    "${var.project_name}.asgi:application",
    "--host", "0.0.0.0",
    "--port", var.port,
    "--interface", "asgi3",
    "--proxy-headers",
    "--log-level", lower(var.web.log_level),
    "--workers", var.web.concurrency
  ]

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  privileged = var.privileged

  dynamic "capabilities" {
    for_each = length(var.cap_add) + length(var.cap_drop) > 0 ? [1] : []
    content {
      add  = var.cap_add
      drop = var.cap_drop
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

  hostname = "${var.identifier}-web"

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
    read_only      = false
  }

  provisioner "local-exec" {
    command = <<EOT
      chown ${var.app_uid}:${var.app_gid} "${local.host_media_directory}"
      chown ${var.app_uid}:${var.app_gid} "${local.host_static_directory}"
    EOT
  }
}
