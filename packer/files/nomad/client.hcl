# /etc/nomad.d/server.hcl

# default region is "global"
# Nomad will identify your server nodes as HOSTNAME.region
datacenter = "{DATACENTER}"
region     = "{REGION}"
name       = "{NAME}"

# Increase log verbosity
log_level = "INFO"

# Setup data dir
data_dir = "/opt/nomad"

bind_addr = "0.0.0.0"

advertise {
  http = "{IPV4_ADDR}"
  rpc  = "{IPV4_ADDR}"
  serf = "{IPV4_ADDR}"
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

# https://www.nomadproject.io/guides/security/acl.html#enable-acls-on-nomad-servers
acl {
  enabled = true

  # For multi-region federation setups
  # From primary DC, create global management token to be passed here
  #replication_token = ""
}

# Enable the server
server {
  enabled = false
}

client {
  enabled = true

  server_join {
    retry_join = ["{SERVER1_ADDR}", "{SERVER2_ADDR}", "{SERVER3_ADDR}"]
  }

  #options {
  #  "driver.raw_exec.enable"    = "1"
  #  "docker.privileged.enabled" = "true"
  #  "driver.docker.enable"      = "1"
  #  "driver.whitelist"          = "docker"
  #  "user.blacklist"            = "root,ubuntu"
  #}
}

#tls {
#  http = true
#  rpc  = true
#
#  ca_file   = "/etc/ssl/certs/nomad-agent-ca.pem"
#  cert_file = "/etc/nomad.d/ssl/{REGION}-server-nomad.pem"
#  key_file  = "/etc/nomad.d/ssl/{REGION}-server-nomad-key.pem"
#
#  verify_server_hostname = true
#  verify_https_client    = false
#}

# https://developer.hashicorp.com/nomad/docs/integrations/vault-integration#authentication-without-workload-identity-legacy
#vault {
#  enabled = true
#  address = "{VAULT_ADDR}"
#  token   = "{VAULT_TOKEN}"
#}

