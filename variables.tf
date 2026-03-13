variable "identifier" {
  type        = string
  description = "Identifier (must be unique, used to name resources)."
  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Toggle the containers (started or stopped)."
}

variable "image_id" {
  type        = string
  description = "Django application's image ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  default     = 1001
  description = "UID of the user running the container and owning the data."
}

variable "app_gid" {
  type        = number
  default     = 1001
  description = "GID of the user running the container and owning the data."
}

variable "privileged" {
  type        = bool
  default     = false
  description = "Run the container in privileged mode."
}

variable "cap_add" {
  type        = set(string)
  default     = []
  description = "Linux capabilities to add to the container."
}

variable "cap_drop" {
  type        = set(string)
  default     = []
  description = "Linux capabilities to drop from the container."
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Add entries to container hosts file."
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "port" {
  type    = number
  default = 8000

  validation {
    condition     = var.port == 8000
    error_message = "Having `port` different than 8000 is not yet implemented."
  }
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Django Application -------------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Django project's name (directory), for example \"DietApp\"."
}

variable "site_name" {
  type        = string
  description = "Django site's name, for example \"Diet Application\"."
}

variable "settings" {
  type        = map(string)
  default     = {}
  description = "Any additional environment variables for the application (e.g. { FOO = \"bar\" })"
}

variable "admin_name" {
  type = string
}

variable "admin_email" {
  type = string
}

variable "admin_url" {
  type    = string
  default = "admin"
}

variable "compress_enabled" {
  type    = bool
  default = false
}

variable "compress_offline" {
  type    = bool
  default = false
}

variable "csrf_trusted_origins" {
  type = list(string)
}

variable "debug" {
  type = bool
}

variable "debug_toolbar" {
  type = bool
}

variable "debug_toolbar_template_profiler" {
  type = bool
}

variable "default_from_email" {
  type = string
}

variable "domains" {
  type = list(string)
}

variable "email_backend" {
  type    = string
  default = "django.core.mail.backends.dummy.EmailBackend"
}

variable "email_file_path" {
  type    = string
  default = ""
}

variable "email_host" {
  type    = string
  default = ""
}

variable "email_host_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "email_host_user" {
  type    = string
  default = ""
}

variable "email_port" {
  type    = number
  default = 465
}

variable "email_subject_prefix" {
  type = string
}

variable "email_use_ssl" {
  type    = bool
  default = true
}

variable "email_use_tls" {
  type    = bool
  default = false
}

variable "managers" {
  type    = list(string)
  default = []
}

# Broker Endpoint ----------------------------------------------------------------------------------

variable "broker_host" {
  type = string
}

variable "broker_port" {
  type    = number
  default = 6379
}

variable "broker_index" {
  type = number
}

variable "broker_password" {
  type      = string
  sensitive = true
}

# Cache

variable "cache_host" {
  type = string
}

variable "cache_port" {
  type    = number
  default = 6379
}

variable "cache_index" {
  type = number
}

variable "cache_password" {
  type      = string
  sensitive = true
}

# Database Endpoint --------------------------------------------------------------------------------

variable "database_host" {
  type = string
}

variable "database_port" {
  type    = number
  default = 5432
}

variable "database_name" {
  type = string
}

variable "database_user" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

# Web Container ------------------------------------------------------------------------------------

variable "web" {
  type = object({
    concurrency = optional(number, 1)
    log_level   = optional(string, "info")
  })
  description = "Web engine settings."

  validation {
    condition     = contains(["critical", "error", "warning", "info", "debug", "trace"], var.web.log_level)
    error_message = "Log level should be one of `critical`, `error`, `warning`, `info`, `debug`, `trace`"
  }
}

# Workers Containers -------------------------------------------------------------------------------

variable "beat" {
  type = object({
    log_level     = optional(string, "info")
    extra_options = optional(list(string), [])
  })
  description = "Celery beat settings."

  validation {
    condition     = contains(["debug", "info", "warning", "error", "critical", "fatal"], var.beat.log_level)
    error_message = "Log level should be one of `debug`, `info`, `warning`, `error`, `critical`, `fatal`"
  }
}

variable "workers" {
  type = map(object({
    name          = string
    queues        = list(string)
    log_level     = optional(string, "info")
    extra_options = optional(list(string), [])
  }))
  description = "Celery workers settings. See `celery worker --help` for detailled description."

  validation {
    condition = alltrue([
      for w in var.workers :
      contains(["debug", "info", "warning", "error", "critical", "fatal"], w.log_level)
    ])
    error_message = "Log level should be one of `debug`, `info`, `warning`, `error`, `critical`, `fatal`"
  }
}
