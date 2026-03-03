# Django App Terraform Module (Dockerized)

Manage a standardized Django application's Web and Celery components.

* Runs in bridge networking mode
* Creates a web container (Uvicorn ASGI), a Celery beat scheduler, and Celery workers (via `for_each`)
* Parameters passed as environment variables stored in a `.env` file
* Generates a random `SECRET_KEY` automatically
* Supports Django Compressor, email backends, and debug toolbar

> **TODO:** Set media & static directory's ownership to app user.

## Usage

See [django-stack examples](https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack/tree/main/examples) for a complete working configuration.

```hcl
module "app" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-app.git?ref=1.0.1"

  identifier     = "my-app"
  enabled        = true
  image_id       = docker_image.app.image_id
  data_directory = "/data/my-app/app"

  # Networking

  hosts      = { "myserver" = "10.0.0.1" }
  network_id = docker_network.app.id

  # Django Application

  project_name         = "MyProject"
  site_name            = "My Application"
  admin_name           = "Admin User"
  admin_email          = "admin@example.com"
  csrf_trusted_origins = ["https://my-app.example.com"]
  debug                = false
  default_from_email   = "noreply@example.com"
  domains              = ["my-app.example.com"]
  email_subject_prefix = "[My App] "

  # Broker & Cache (Redis)

  broker_host     = module.broker.host
  broker_port     = module.broker.port
  broker_index    = 0
  broker_password = module.broker.password

  cache_host     = module.broker.host
  cache_port     = module.broker.port
  cache_index    = 1
  cache_password = module.broker.password

  # Database (PostgreSQL)

  database_host     = module.database.host
  database_port     = module.database.port
  database_name     = module.database.name
  database_user     = module.database.user
  database_password = module.database.password

  # Containers

  web = {
    concurrency = 4
    log_level   = "info"
  }

  beat = {
    log_level = "info"
  }

  workers = {
    default = {
      name      = "default"
      queues    = ["default"]
      log_level = "info"
    }
  }
}
```

## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── config/     # Generated settings.env
├── media/      # User-uploaded media files
├── protected/  # Protected files (served via X-Accel-Redirect)
├── static/     # Collected static files
└── workers/    # Celery beat and worker state databases
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | — | Start or stop the containers. |
| `image_id` | `string` | — | Django application Docker image's ID (custom image). |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `data_owner` | `string` | `"1001:1001"` | UID:GID for data directories. |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the containers. |
| `network_id` | `string` | — | Docker network to attach to. |
| `port` | `number` | `8000` | Web port (changing not yet implemented). |
| `project_name` | `string` | — | Django project directory name. |
| `site_name` | `string` | — | Django site display name. |
| `settings` | `map(string)` | `{}` | Additional environment variables. |
| `admin_name` | `string` | — | Admin display name. |
| `admin_email` | `string` | — | Admin email address. |
| `admin_url` | `string` | `"admin"` | Admin URL prefix. |
| `compress_enabled` | `bool` | `false` | Enable Django Compressor. |
| `compress_offline` | `bool` | `false` | Enable offline compression. |
| `csrf_trusted_origins` | `list(string)` | — | CSRF trusted origins. |
| `debug` | `bool` | — | Enable Django debug mode. |
| `debug_toolbar` | `bool` | — | Enable Django Debug Toolbar. |
| `debug_toolbar_template_profiler` | `bool` | — | Enable template profiler. |
| `default_from_email` | `string` | — | Default sender email. |
| `domains` | `list(string)` | — | Allowed domains (ALLOWED_HOSTS). |
| `email_backend` | `string` | `"django.core.mail.backends.dummy.EmailBackend"` | Email backend class. |
| `email_host` | `string` | `""` | SMTP host. |
| `email_host_password` | `string` | `""` | SMTP password (sensitive). |
| `email_host_user` | `string` | `""` | SMTP username. |
| `email_port` | `number` | `465` | SMTP port. |
| `email_subject_prefix` | `string` | — | Email subject prefix. |
| `email_use_ssl` | `bool` | `true` | Use SSL for SMTP. |
| `email_use_tls` | `bool` | `false` | Use TLS for SMTP. |
| `email_file_path` | `string` | `""` | File path for file-based email backend. |
| `managers` | `list(string)` | `[]` | Django MANAGERS setting. |
| `broker_host` | `string` | — | Redis broker hostname. |
| `broker_port` | `number` | `6379` | Redis broker port. |
| `broker_index` | `number` | — | Redis broker database index. |
| `broker_password` | `string` | — | Redis broker password (sensitive). |
| `cache_host` | `string` | — | Redis cache hostname. |
| `cache_port` | `number` | `6379` | Redis cache port. |
| `cache_index` | `number` | — | Redis cache database index. |
| `cache_password` | `string` | — | Redis cache password (sensitive). |
| `database_host` | `string` | — | PostgreSQL hostname. |
| `database_port` | `number` | `5432` | PostgreSQL port. |
| `database_name` | `string` | — | PostgreSQL database name. |
| `database_user` | `string` | — | PostgreSQL user. |
| `database_password` | `string` | — | PostgreSQL password (sensitive). |
| `web` | `object` | — | Web engine settings (`concurrency`, `log_level`). |
| `beat` | `object` | — | Celery beat settings (`log_level`, `extra_options`). |
| `workers` | `map(object)` | — | Celery workers settings (`name`, `queues`, `log_level`, `extra_options`). |

## Outputs

| Name | Description |
|------|-------------|
| `media_directory` | Host path to media directory. |
| `protected_directory` | Host path to protected directory. |
| `static_directory` | Host path to static directory. |
| `host` | Web container hostname. |
| `port` | Web port. |

## Requirements

* Terraform >= 1.6
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 3.0.2
* [hashicorp/local](https://github.com/hashicorp/terraform-provider-local) >= 2.4.1
* [hashicorp/random](https://github.com/hashicorp/terraform-provider-random) >= 3.6.0
