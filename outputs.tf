output "media_directory" {
  value = local.media_directory
}

output "static_directory" {
  value = local.static_directory
}

output "host" {
  value = docker_container.web.hostname
}

output "port" {
  value = var.port
}
