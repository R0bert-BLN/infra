output "database_url" {
  value     = one(module.database[*].url)
  sensitive = true
}

output "issuer_url" {
  description = "OIDC issuer; discovery is at <issuer>/.well-known/openid-configuration"
  value       = var.auth == null ? null : "${var.keycloak_url}/realms/${module.auth[0].realm}"
}

output "web_client_id" {
  value = one(module.auth[*].web_client_id)
}

output "web_client_secret" {
  value     = one(module.auth[*].web_client_secret)
  sensitive = true
}

output "mobile_client_id" {
  value = one(module.auth[*].mobile_client_id)
}
