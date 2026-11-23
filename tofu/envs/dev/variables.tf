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
