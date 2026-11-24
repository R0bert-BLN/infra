output "realm" {
  value = keycloak_realm.this.realm
}

output "web_client_id" {
  value = one(keycloak_openid_client.web[*].client_id)
}

output "web_client_secret" {
  value     = one(keycloak_openid_client.web[*].client_secret)
  sensitive = true
}

output "mobile_client_id" {
  value = one(keycloak_openid_client.mobile[*].client_id)
}
