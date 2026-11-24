# Vault instructions

1. Fill in TS_AUTHKEY and TS_DOMAIN in .env.
1. Start it: docker compose up -d.
1. Initialize it: `docker exec -it app-vault vault operator init -key-shares=1 -key-threshold=1`
1. Unseal it: `docker exec -it app-vault vault operator unseal`
