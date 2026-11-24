# infra

Shared infrastructure for self-hosted projects: reverse proxy, database, identity provider
and provisioning, defined with Docker Compose and OpenTofu. The same stack runs in dev
(laptop), on the home server (Tailscale) and in prod (Cloudflare Tunnel).

## Stack

| Component | Purpose |
|---|---|
| Traefik | Reverse proxy, routes `<name>.${DOMAIN}` via Docker labels |
| Postgres + PostGIS | Shared database server, one role and database per project and environment |
| Keycloak | OIDC provider at `auth.${DOMAIN}`, one realm per project and environment |
| Mailpit | Dev-only SMTP sink at `mail.${DOMAIN}` |
| OpenTofu | Provisions databases, realms and OIDC clients |

Networks: `edge` (everything behind Traefik) and `data` (Postgres clients). Host ports bind
to `127.0.0.1` only.

| Profile | Services |
|---|---|
| *(none)* | `traefik`, `postgres`, `keycloak` |
| `dev` | `mailpit`, `whoami` |
| `setup` | `keycloak-db-init` |
| `tools` | `tofu` |

## Requirements

Docker with Compose v2, `make`, `openssl`.

## Configuration

```sh
cp .env.example .env
```

| Key | Dev | Server |
|---|---|---|
| `DOMAIN` | `localhost` | `<tailnet>.ts.net` / `<domain>` |
| `PUBLIC_SCHEME` | `http` | `https` |
| `COMPOSE_PROFILES` | `dev` | *(empty)* |
| `TOFU_ENV` | `dev` | `server` |

| Key | Value |
|---|---|
| `POSTGRES_SUPERUSER` | e.g. `postgres` |
| `POSTGRES_SUPERUSER_PASSWORD`, `KEYCLOAK_DB_PASSWORD` | `openssl rand -base64 24` |
| `KEYCLOAK_ADMIN_USERNAME`, `KEYCLOAK_ADMIN_PASSWORD` | temporary admin, first start only |
| `TOFU_STATE_PASSPHRASE` | `openssl rand -base64 32` |
| `KEYCLOAK_TOFU_CLIENT_SECRET` | empty until [Keycloak setup](#keycloak-setup) |

Leave host ports and image versions empty to use the defaults. In dev, `TRAEFIK_PORT` must
stay `80`.

## Getting started

```sh
make up
```

| URL | Service |
|---|---|
| `http://auth.localhost/admin` | Keycloak admin console |
| `http://mail.localhost` | Mailpit |
| `http://whoami.localhost` | Request echo |
| `http://localhost:8080/dashboard/` | Traefik dashboard |

### Keycloak setup

Once per Keycloak instance, in the `master` realm:

1. Log in with the temporary admin.
2. **Users → Add user**: set a password and assign the `admin` realm role. Log in as this
   user and delete the temporary admin.
3. **Clients → Create client**, Client ID `tofu`: Client authentication **On**, Standard
   flow **Off**, Direct access grants **Off**, Service accounts roles **On**.
4. **Service accounts roles**: assign the `admin` realm role.
5. **Credentials**: copy the secret to `.env` as `KEYCLOAK_TOFU_CLIENT_SECRET`.

### Provisioning

```sh
make tofu args=init
make tofu args=plan
make tofu args=apply
make tofu args="output -raw squadplay_database_url"
```

## Adding a project

Compose (in the project repository):

```yaml
services:
  app:
    networks: [edge, data]
    labels:
      - traefik.enable=true
      - traefik.http.routers.myapp.entrypoints=web
      - traefik.http.routers.myapp.rule=Host(`myapp.${DOMAIN}`)
      - traefik.http.routers.myapp.middlewares=public@file
      - traefik.http.services.myapp.loadbalancer.server.port=8080
networks:
  edge: { external: true }
  data: { external: true }
```

OpenTofu, `tofu/envs/<TOFU_ENV>/myapp.tf`. Every block is optional; omit `database` or
`auth` to skip it.

```hcl
module "myapp_dev" {
  source = "../../modules/project"

  name         = "myapp"
  env          = "dev"
  keycloak_url = local.keycloak_url
  smtp         = local.smtp

  database = {}

  auth = {
    display_name = "My App"
    email_from   = "hello@myapp.localhost" # default: noreply@myapp.localhost

    web = {
      redirect_uris = ["http://myapp.localhost/auth/callback"]
    }
    mobile = {
      redirect_uris = ["com.myapp.app:/callback"]
    }
  }
}

output "myapp_database_url" {
  value     = module.myapp_dev.database_url
  sensitive = true
}

output "myapp_issuer_url" {
  value = module.myapp_dev.issuer_url
}
```

Module outputs: `database_url`, `issuer_url`, `web_client_id`, `web_client_secret`,
`mobile_client_id`.

Inside containers: Postgres is `postgres:5432`, Keycloak (dev) is `http://auth.localhost`,
SMTP (dev) is `mailpit:1025`.

## Server

Create `tofu/envs/server` from `envs/dev` with the server URLs, then publish Traefik through
Tailscale Services:

```sh
sudo tailscale serve --service=svc:auth    --https=443 http://127.0.0.1:80
sudo tailscale serve --service=svc:traefik --https=443 http://127.0.0.1:8080
```

## Commands

| Command | Description |
|---|---|
| `make up` | Create networks, run setup jobs, build and start services |
| `make down` | Stop all services, all profiles |
| `make ps` / `make logs s=<service>` | Status / logs |
| `make tofu args="..."` | Run OpenTofu in `tofu/envs/${TOFU_ENV}` |
| `make check` | Validate compose, `tofu fmt`, `tofu validate` (also run in CI) |

Reset dev (deletes all data):

```sh
docker compose --env-file .env --profile "*" down -v
rm tofu/envs/dev/terraform.tfstate*
```
