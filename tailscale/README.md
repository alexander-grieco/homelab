# Tailscale serve

## Future plans

NOTE: Must wait until Tailscale version 1.106 to run below
`tailscale serve set-config --all serve.json`

To check if tailscale is up to date on NixOS
`nix flake update
nix eval .#nixosConfigurations.framework-pc.config.services.tailscale.package.version`

## Workaround for now

Until then run manually:
`tailscale serve --service=svc:vault --tls-terminated-tcp=443 tcp://127.0.0.1:8200`

And check the status:
`tailscale serve status`
