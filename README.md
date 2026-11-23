# infra

Shared infrastructure for personal projects, run with Docker Compose. One stack provides routing,
a database and identity for every app, and the same config runs on a dev laptop, on a home
server (private, through Tailscale) and in prod (public, through Cloudflare Tunnel).

| Component | Role |
|---|---|
| **Traefik** | Reverse proxy. Routes `<name>.${DOMAIN}` to containers based on Docker labels |
| **Postgres + PostGIS** | One shared server; each project and environment gets its own role and database |
| **Zitadel v4** | OIDC identity provider (API + login UI). Each project gets its own organization |
| **OpenTofu** | Provisions the per-project databases, organizations and OIDC clients. Runs in a container |

Two Docker networks connect everything: `edge` (Traefik and anything it routes to) and
`data` (Postgres and its clients). Nothing listens on a public port; Traefik and Postgres
bind to `127.0.0.1`.

## Modes

Set these four variables together in `.env`:

| Variable | Dev (laptop) | Server (Tailscale Services) | Prod (Cloudflare) |
|---|---|---|---|
| `DOMAIN` | `localhost` | `<tailnet>.ts.net` | `<your-domain>` |
| `PUBLIC_SCHEME` | `http` | `https` | `https` |
| `PUBLIC_PORT` | `80` | `443` | `443` |
| `PUBLIC_SECURE` | `false` | `true` | `true` |

In dev, keep `TRAEFIK_PORT` equal to `PUBLIC_PORT` (`80`).

## Setup

1. `cp .env.example .env` and fill it in:
   - passwords: `openssl rand -base64 24`
   - `ZITADEL_ADMIN_PASSWORD`: 8+ characters with an uppercase letter, a lowercase letter,
     a digit and a symbol, e.g. `echo "$(openssl rand -base64 18)Aa1!"`
   - `ZITADEL_MASTERKEY`: `openssl rand -hex 16` (exactly 32 characters)
   - `ZITADEL_LOGIN_COOKIE_SECRET`, `TOFU_STATE_PASSPHRASE`: `openssl rand -base64 32`
   - `TOFU_ENV`: `dev` on a laptop, `server` on the server
2. `make up` creates the networks, runs the one-shot Zitadel jobs (init, then setup with
   the migrations) and starts everything.
3. Zitadel console: `<scheme>://auth.<DOMAIN>/ui/console`. Log in as
   `admin@zitadel.auth.<DOMAIN>` with `ZITADEL_ADMIN_PASSWORD` (you'll change it on first
   login). Traefik dashboard: `http://localhost:8080/dashboard/`.

On the server, publish Traefik through Tailscale Services:

```sh
sudo tailscale serve --service=svc:auth    --https=443 http://127.0.0.1:80
sudo tailscale serve --service=svc:traefik --https=443 http://127.0.0.1:8080
```

`make help` lists the other targets.

## Adding a project

**Routing.** Join the external `edge` network (and `data` if the app needs Postgres), then
add labels:

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

From inside containers, Postgres is `postgres:5432` and Zitadel is `http://auth.localhost`
in dev (a network alias on Traefik).

**Database and login.** Add one file per project in `tofu/envs/<TOFU_ENV>/`, e.g.
`myapp.tf`, that calls the `project` module. Give it `web` (a backend with a client secret),
`mobile` (a native app using PKCE, no secret), or both:

```hcl
module "myapp_dev" {
  source   = "../../modules/project"
  name     = "myapp"
  env      = "dev"
  dev_mode = true # allows http:// redirect URIs

  web = {
    redirect_uris = ["http://myapp.localhost/auth/callback"]
  }
}

output "myapp_database_url" {
  value     = module.myapp_dev.database_url
  sensitive = true
}

output "myapp_web_client_id" {
  value = module.myapp_dev.web_client_id
}
```

This creates the role and database `myapp_dev`, plus a Zitadel organization, project and
OIDC app named `myapp-dev`. The module also outputs `web_client_secret`,
`mobile_client_id` and `zitadel_org_id`.

## OpenTofu

One-time setup:

1. In the Zitadel console, create a service user `tofu` (JWT token type), add a JSON key
   and save it as `tofu/envs/<TOFU_ENV>/zitadel-key.json` (gitignored).
2. Give it the **IAM Owner** instance role. It needs this to create organizations.

Then:

```sh
make tofu args=init
make tofu args=plan
make tofu args=apply
make tofu args="output -raw myapp_database_url"
```
