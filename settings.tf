resource "random_string" "secret_key" {
  length           = 32
  override_special = "!@%&*()-_=+[]{}<>:"
}

resource "local_file" "settings" {
  filename             = "${local.config_directory}/settings.env"
  content              = join("\n", [for k, v in local.settings : "${k}=\"${v}\""])
  file_permission      = "0644"
  directory_permission = "0755"
}
