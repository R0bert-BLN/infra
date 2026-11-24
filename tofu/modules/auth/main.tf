resource "keycloak_realm" "this" {
  realm        = var.realm
  display_name = var.display_name

  registration_allowed     = var.registration_allowed
  reset_password_allowed   = var.smtp != null
  verify_email             = var.smtp != null
  login_with_email_allowed = true
  duplicate_emails_allowed = false
  remember_me              = true

  ssl_required    = "external"
  password_policy = "length(12)"

  dynamic "smtp_server" {
    for_each = var.smtp == null ? [] : [var.smtp]

    content {
      host              = smtp_server.value.host
      port              = smtp_server.value.port
      from              = smtp_server.value.from
      from_display_name = smtp_server.value.from_display_name
    }
  }
}

resource "keycloak_openid_client" "web" {
  count = var.web == null ? 0 : 1

  realm_id    = keycloak_realm.this.id
  client_id   = "web"
  name        = "Web"
  access_type = "CONFIDENTIAL"

  standard_flow_enabled        = true
  direct_access_grants_enabled = false

  valid_redirect_uris             = var.web.redirect_uris
  valid_post_logout_redirect_uris = var.web.post_logout_redirect_uris
  web_origins                     = var.web.web_origins
}

resource "keycloak_openid_client" "mobile" {
  count = var.mobile == null ? 0 : 1

  realm_id    = keycloak_realm.this.id
  client_id   = "mobile"
  name        = "Mobile"
  access_type = "PUBLIC"

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  pkce_code_challenge_method   = "S256"

  valid_redirect_uris             = var.mobile.redirect_uris
  valid_post_logout_redirect_uris = var.mobile.post_logout_redirect_uris
}
