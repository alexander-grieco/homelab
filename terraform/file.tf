data "local_sensitive_file" "private_key" {
  filename = pathexpand(var.private_key_file)
}

