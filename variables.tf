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
  description = "Toggle the containers (started or stopped)."
  default     = true
}

variable "image_id" {
  type        = string
  description = "Django application's image ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  description = "UID of the user running the container and owning the data."
  default     = 1001
}

variable "app_gid" {
  type        = number
  description = "GID of the user running the container and owning the data."
  default     = 1001
}

variable "privileged" {
  type        = bool
  description = "Run the container in privileged mode."
  default     = false
}

variable "cap_add" {
  type        = set(string)
  description = "Linux capabilities to add to the container."
  default     = []
  validation {
    condition = length(setsubtract(var.cap_add, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_add` must be a valid Linux capability name."
  }
}

variable "cap_drop" {
  type        = set(string)
  description = "Linux capabilities to drop from the container."
  default     = []
  validation {
    condition = length(setsubtract(var.cap_drop, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_drop` must be a valid Linux capability name."
  }
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "port" {
  type        = number
  description = "Bind the Django application's HTTP port."
  default     = 8000

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
  description = "Any additional environment variables for the application (e.g. { FOO = \"bar\" })"
  default     = {}
}

variable "admin_name" {
  type        = string
  description = "Django admin full name."
}

variable "admin_email" {
  type        = string
  description = "Django admin email address."

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.admin_email))
    error_message = "Argument `admin_email` must be a valid email address."
  }
}

variable "admin_url" {
  type        = string
  description = "URL path for the Django admin interface."
  default     = "admin"

  validation {
    condition     = length(var.admin_url) > 0
    error_message = "Argument `admin_url` must not be empty."
  }
}

variable "compress_enabled" {
  type        = bool
  description = "Enable Django Compressor."
  default     = false
}

variable "compress_offline" {
  type        = bool
  description = "Enable Django Compressor offline compression."
  default     = false
}

variable "csrf_trusted_origins" {
  type        = list(string)
  description = "List of trusted origins for CSRF protection."
}

variable "debug" {
  type        = bool
  description = "Enable Django debug mode."
  default     = false
}

variable "debug_toolbar" {
  type        = bool
  description = "Enable Django Debug Toolbar."
  default     = false
}

variable "debug_toolbar_template_profiler" {
  type        = bool
  description = "Enable template profiler in Django Debug Toolbar."
  default     = false
}

variable "default_from_email" {
  type        = string
  description = "Default sender address for outgoing emails."

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.default_from_email))
    error_message = "Argument `default_from_email` must be a valid email address."
  }
}

variable "domains" {
  type        = list(string)
  description = "Allowed domains for the application (used in nginx server_name)."
}

variable "email_backend" {
  type        = string
  description = "Django email backend class."
  default     = "django.core.mail.backends.dummy.EmailBackend"
}

variable "email_file_path" {
  type        = string
  description = "File path for the file-based email backend."
  default     = ""
}

variable "email_host" {
  type        = string
  description = "SMTP server hostname."
  default     = ""
}

variable "email_host_password" {
  type        = string
  description = "SMTP server password."
  default     = ""
  sensitive   = true
}

variable "email_host_user" {
  type        = string
  description = "SMTP server username."
  default     = ""
}

variable "email_port" {
  type        = number
  description = "SMTP server port."
  default     = 465

  validation {
    condition     = var.email_port >= 1 && var.email_port <= 65535
    error_message = "Argument `email_port` must be between 1 and 65535."
  }
}

variable "email_subject_prefix" {
  type        = string
  description = "Prefix prepended to the subject of emails sent to admins and managers."
}

variable "email_use_ssl" {
  type        = bool
  description = "Use implicit TLS (SMTPS) when connecting to the SMTP server."
  default     = true
}

variable "email_use_tls" {
  type        = bool
  description = "Use explicit TLS (STARTTLS) when connecting to the SMTP server."
  default     = false
}

variable "managers" {
  type        = list(string)
  description = "List of manager email addresses to receive broken link notifications."
  default     = []

  validation {
    condition     = alltrue([for m in var.managers : can(regex("^[^@]+@[^@]+$", m))])
    error_message = "Each entry in `managers` must be a valid email address."
  }
}

# Broker Endpoint ----------------------------------------------------------------------------------

variable "broker_host" {
  type        = string
  description = "Redis broker hostname."
}

variable "broker_port" {
  type        = number
  description = "Redis broker port."
  default     = 6379

  validation {
    condition     = var.broker_port >= 1 && var.broker_port <= 65535
    error_message = "Argument `broker_port` must be between 1 and 65535."
  }
}

variable "broker_index" {
  type        = number
  description = "Redis database index for the broker."
  default     = 0

  validation {
    condition     = var.broker_index >= 0
    error_message = "Argument `broker_index` must be 0 or a positive integer."
  }
}

variable "broker_password" {
  type        = string
  description = "Redis broker password."
  sensitive   = true
}

# Cache Endpoint -----------------------------------------------------------------------------------

variable "cache_host" {
  type        = string
  description = "Redis cache hostname."
}

variable "cache_port" {
  type        = number
  description = "Redis cache port."
  default     = 6379

  validation {
    condition     = var.cache_port >= 1 && var.cache_port <= 65535
    error_message = "Argument `cache_port` must be between 1 and 65535."
  }
}

variable "cache_index" {
  type        = number
  description = "Redis database index for the cache."
  default     = 1

  validation {
    condition     = var.cache_index >= 0
    error_message = "Argument `cache_index` must be 0 or a positive integer."
  }
}

variable "cache_password" {
  type        = string
  description = "Redis cache password."
  sensitive   = true
}

# Database Endpoint --------------------------------------------------------------------------------

variable "database_host" {
  type        = string
  description = "PostgreSQL database hostname."
}

variable "database_port" {
  type        = number
  description = "PostgreSQL database port."
  default     = 5432

  validation {
    condition     = var.database_port >= 1 && var.database_port <= 65535
    error_message = "Argument `database_port` must be between 1 and 65535."
  }
}

variable "database_name" {
  type        = string
  description = "PostgreSQL database name."

  validation {
    condition     = length(var.database_name) > 0
    error_message = "Argument `database_name` must not be empty."
  }
}

variable "database_user" {
  type        = string
  description = "PostgreSQL database user."

  validation {
    condition     = length(var.database_user) > 0
    error_message = "Argument `database_user` must not be empty."
  }
}

variable "database_password" {
  type        = string
  description = "PostgreSQL database password."
  sensitive   = true
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
