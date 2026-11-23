provider "postgresql" {
  host            = "postgres"
  port            = 5432
  username        = var.pg_superuser
  password        = var.pg_superuser_password
  sslmode         = "disable"
  connect_timeout = 15
}

provider "zitadel" {
  domain           = "auth.localhost"
  insecure         = true
  port             = "80"
  jwt_profile_file = "${path.module}/zitadel-key.json"
}
