locals {
  container_settings_path     = "/home/app/src/${var.project_name}/.env"
  container_media_directory   = "/data/media"
  container_static_directory  = "/data/static"
  container_workers_directory = "/data/workers"

  host_config_directory  = "${var.data_directory}/config"
  host_media_directory   = "${var.data_directory}/media"
  host_static_directory  = "${var.data_directory}/static"
  host_workers_directory = "${var.data_directory}/workers"

  settings = merge(var.settings, local.forced_settings)

  forced_settings = {
    ADMIN_URL                       = var.admin_url,
    BROKER_HOST                     = var.broker_host,
    BROKER_INDEX                    = var.broker_index,
    BROKER_PASSWORD                 = var.broker_password,
    BROKER_PORT                     = var.broker_port,
    CACHE_HOST                      = var.cache_host,
    CACHE_INDEX                     = var.cache_index,
    CACHE_PASSWORD                  = var.cache_password,
    CACHE_PORT                      = var.cache_port,
    COMMON_SITE_NAME                = var.site_name,
    COMPRESS_ENABLED                = var.compress_enabled ? "True" : "False",
    COMPRESS_OFFLINE                = var.compress_enabled && var.compress_offline ? "True" : "false",
    CSRF_TRUSTED_ORIGINS            = join(" ", var.csrf_trusted_origins),
    DATABASE_HOST                   = var.database_host,
    DATABASE_NAME                   = var.database_name,
    DATABASE_PASSWORD               = var.database_password,
    DATABASE_PORT                   = var.database_port,
    DATABASE_USER                   = var.database_user,
    DEBUG                           = var.debug ? "True" : "False",
    DEBUG_TOOLBAR                   = var.debug_toolbar ? "True" : "False",
    DEBUG_TOOLBAR_TEMPLATE_PROFILER = var.debug_toolbar_template_profiler ? "True" : "false",
    DEFAULT_FROM_EMAIL              = var.default_from_email,
    DOMAINS                         = join(" ", var.domains),
    EMAIL_BACKEND                   = var.email_backend,
    EMAIL_FILE_PATH                 = var.email_file_path,
    EMAIL_HOST                      = var.email_host,
    EMAIL_HOST_PASSWORD             = var.email_host_password,
    EMAIL_HOST_USER                 = var.email_host_user,
    EMAIL_PORT                      = var.email_port,
    EMAIL_SUBJECT_PREFIX            = var.email_subject_prefix,
    EMAIL_USE_SSL                   = var.email_use_ssl ? "True" : "False",
    EMAIL_USE_TLS                   = var.email_use_tls ? "True" : "False",
    MANAGERS                        = join(" ", var.managers),
    MEDIA_ROOT                      = local.container_media_directory,
    SECRET_KEY                      = random_string.secret_key.result,
    STATIC_ROOT                     = local.container_static_directory
  }
}
