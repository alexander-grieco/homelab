# Vault server config. Mounted read-only at /vault/config/vault.hcl.
ui = true

# Integrated Storage (Raft), single node. Gives consistent live backups:
#   docker exec app-vault vault operator raft snapshot save /vault/file/backup.snap
#   and lets more nodes join later if Vault ever runs on other machines.
storage "raft" {
  path    = "/vault/file"
  node_id = "vault-1"
}

# Required by Raft: address for node-to-node traffic. Single node, so localhost.
cluster_addr = "http://127.0.0.1:8201"

disable_mlock = true # recommended for raft setups

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}
