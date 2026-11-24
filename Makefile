ENV_FILE ?= .env
COMPOSE := docker compose --env-file $(ENV_FILE)
TOFU := HOST_UID=$$(id -u) HOST_GID=$$(id -g) $(COMPOSE) run --rm tofu
EDGE_SUBNET := 10.123.0.0/24

.PHONY: help networks up down restart ps logs config setup tofu check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

networks: ## Create the shared networks
	@docker network inspect edge >/dev/null 2>&1 || docker network create --subnet $(EDGE_SUBNET) edge
	@docker network inspect data >/dev/null 2>&1 || docker network create data

setup: networks ## Run the setup jobs
	$(COMPOSE) run --rm -T keycloak-db-init

up: networks setup ## Start all services
	$(COMPOSE) up -d --build --wait

down: ## Stop all services
	$(COMPOSE) --profile "*" down

restart: ## Restart all services
	$(MAKE) down
	$(MAKE) up

ps: ## Show service status
	$(COMPOSE) ps

logs: ## Follow logs (one service with s=<name>)
	$(COMPOSE) logs -f $(s)

config: ## Show the effective configuration
	$(COMPOSE) config

tofu: networks ## Run OpenTofu
	@ mkdir -p tofu/.plugin-cache
	@ $(TOFU) $(args)

check: networks ## Run the checks
	@ mkdir -p tofu/.plugin-cache
	$(COMPOSE) --profile "*" config -q
	$(TOFU) -chdir=/work fmt -check -recursive
	$(TOFU) init -backend=false -input=false
	$(TOFU) validate
