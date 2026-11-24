# Vault server config. Mounted read-only at /vault/config/vault.hcl.
# Reference: https://developer.hashicorp.com/vault/docs/configuration

ui = true
api_addr = "https://vault.tail50ac.ts.net"

# Integrated Storage (Raft), single node. Live backup:
#   docker exec app-vault vault operator raft snapshot save /vault/file/backup.snap
storage "raft" {
  path    = "/vault/file"
  node_id = "vault-1"
}
cluster_addr  = "http://127.0.0.1:8201"
disable_mlock = true # recommended for Raft; host swap is encrypted

plugin_directory = "/vault/plugins"

# Plain HTTP inside the container. Docker publishes it on the host's
# 127.0.0.1:8200 only; Tailscale serves HTTPS at vault.<tailnet>.ts.net.
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}
