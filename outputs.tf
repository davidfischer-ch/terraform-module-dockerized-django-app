output "media_directory" {
  value = local.host_media_directory
}

output "static_directory" {
  value = local.host_static_directory
}

output "host" {
  value = docker_container.web.hostname
}

output "port" {
  value = var.port
}
