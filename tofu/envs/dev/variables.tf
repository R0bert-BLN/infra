variable "state_passphrase" {
  description = "Encrypts the state"
  type        = string
  sensitive   = true
}

variable "pg_superuser" {
  description = "Postgres superuser that creates roles and databases"
  type        = string
}

variable "pg_superuser_password" {
  description = "Password of the Postgres superuser"
  type        = string
  sensitive   = true
}

variable "keycloak_client_secret" {
  description = "Secret of the tofu client in the master realm"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.keycloak_client_secret) > 0
    error_message = "Set KEYCLOAK_TOFU_CLIENT_SECRET in .env."
  }
}
