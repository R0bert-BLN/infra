provider "postgresql" {
  host            = "postgres"
  port            = 5432
  username        = var.pg_superuser
  password        = var.pg_superuser_password
  sslmode         = "disable"
  connect_timeout = 15
}

provider "keycloak" {
  url           = local.keycloak_url
  client_id     = "tofu"
  client_secret = var.keycloak_client_secret
}
