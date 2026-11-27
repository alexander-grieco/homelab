# Add a name here (plus its entry in serve.json and its services/<name>/ folder)
# to publish a new app at https://<name>.<tailnet>.ts.net.
locals {
  services = [
    "vault",
    "caddy",
    # "immich",
  ]
}

resource "tailscale_acl" "policy" {
  acl = file("${path.module}/policy.hujson")
}

resource "tailscale_service" "homelab" {
  for_each = toset(local.services)

  name  = "svc:${each.key}"
  ports = ["tcp:443"]
  tags  = ["tag:homelab"]

  # The tag must exist (in the policy) before a Service can use it.
  depends_on = [tailscale_acl.policy]
}
