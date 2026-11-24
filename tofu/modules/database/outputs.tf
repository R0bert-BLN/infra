output "url" {
  description = "Connection string as seen from containers on the data network"
  value       = "postgres://${postgresql_role.this.name}:${random_password.this.result}@postgres:5432/${postgresql_database.this.name}?sslmode=disable"
  sensitive   = true
}
