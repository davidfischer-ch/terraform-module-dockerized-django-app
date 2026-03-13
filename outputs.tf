output "media_directory" {
  description = "Host path of the media files directory."
  value       = local.host_media_directory
}

output "protected_directory" {
  description = "Host path of the protected files directory."
  value       = local.host_protected_directory
}

output "static_directory" {
  description = "Host path of the static files directory."
  value       = local.host_static_directory
}

output "host" {
  description = "Hostname of the Django web container."
  value       = docker_container.web.hostname
}

output "port" {
  description = "HTTP port bound by the application."
  value       = var.port
}
