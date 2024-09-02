output "consul_bootstrap_token" {
  description = "The Consul bootstrap acl token."
  value       = random_uuid.consul_bootstrap_token.result
}
