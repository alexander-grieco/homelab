# Vault server config. Mounted read-only at /vault/config/vault.hcl.
# Reference: https://developer.hashicorp.com/vault/docs/configuration
ui = true

storage "file" {
  path = "/vault/file"
}

# sidecar serves HTTPS at https://vault.<tailnet>.ts.net.
listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}
