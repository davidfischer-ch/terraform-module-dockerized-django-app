resource "terraform_data" "data_directories" {
  triggers_replace = [
    local.host_media_directory,
    local.host_protected_directory,
    local.host_static_directory,
    local.host_workers_directory
  ]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p '${local.host_media_directory}'
      mkdir -p '${local.host_protected_directory}'
      mkdir -p '${local.host_static_directory}'
      mkdir -p '${local.host_workers_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_media_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_protected_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_static_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_workers_directory}'
    EOT
  }
}
