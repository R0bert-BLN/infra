output "database_url" {
  description = "Connection string as seen from containers on the data network"
  value       = "postgres://${postgresql_role.this.name}:${random_password.this.result}@postgres:5432/${postgresql_database.this.name}?sslmode=disable"
  sensitive   = true
}

output "zitadel_org_id" {
  description = "Send as scope urn:zitadel:iam:org:id:<id> so users log in and register in this org"
  value       = zitadel_org.this.id
}

output "web_client_id" {
  description = "Confidential client: authenticates with client_id + client_secret"
  value       = nonsensitive(one(zitadel_application_oidc.web[*].client_id))
}

output "web_client_secret" {
  description = "Confidential client: authenticates with client_id + client_secret"
  value       = one(zitadel_application_oidc.web[*].client_secret)
  sensitive   = true
}

output "mobile_client_id" {
  description = "Public client: no secret, the mobile apps uses PKCE"
  value       = nonsensitive(one(zitadel_application_oidc.mobile[*].client_id))
}
