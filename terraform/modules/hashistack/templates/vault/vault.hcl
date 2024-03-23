storage "consul" {
  address       = "127.0.0.1:8501"
  path          = "vault/"
  token         = "${consul_bootstrap_token}"
  tls_ca_file   = "${consul_ca_file}"
  tls_cert_file = "${consul_cert_file}"
  tls_key_file  = "${consul_key_file}"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 0
  tls_ca_file     = "${vault_ca_file}"
  tls_cert_file   = "${vault_cert_file}"
  tls_key_file    = "${vault_key_file}"
}

#seal "awskms" {
#  region = "us-east-1"
#  kms_key_id = "12345678-abcd-1234-abcd-123456789101",
#  endpoint = "example.kms.us-east-1.vpce.amazonaws.com"
#}

#api_addr = "https://127.0.0.1:8200"
#cluster_addr = " https://127.0.0.1:8201"
#cluster_name = "vault-prod-us-east-1"
ui        = true
log_level = "INFO"
