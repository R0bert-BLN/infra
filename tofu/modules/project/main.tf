locals {
  db_name = "${var.name}_${var.env}"
}

# Postgres
resource "random_password" "this" {
  length  = 32
  special = false
}

resource "postgresql_role" "this" {
  name     = local.db_name
  login    = true
  password = random_password.this.result
}

resource "postgresql_database" "this" {
  name  = local.db_name
  owner = postgresql_role.this.name
}

# Zitadel
resource "zitadel_org" "this" {
  name = "${var.name}-${var.env}"
}

resource "zitadel_project" "this" {
  org_id                   = zitadel_org.this.id
  name                     = "${var.name}-${var.env}"
  private_labeling_setting = "PRIVATE_LABELING_SETTING_ENFORCE_PROJECT_RESOURCE_OWNER_POLICY"
}

resource "zitadel_application_oidc" "web" {
  count = var.web == null ? 0 : 1

  org_id     = zitadel_org.this.id
  project_id = zitadel_project.this.id
  name       = "${var.name}-${var.env}-web"

  redirect_uris             = var.web.redirect_uris
  post_logout_redirect_uris = var.web.post_logout_redirect_uris

  app_type         = "OIDC_APP_TYPE_WEB"
  response_types   = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types      = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  access_token_type = "OIDC_TOKEN_TYPE_JWT"
  dev_mode          = var.dev_mode
}

resource "zitadel_application_oidc" "mobile" {
  count = var.mobile == null ? 0 : 1

  org_id     = zitadel_org.this.id
  project_id = zitadel_project.this.id
  name       = "${var.name}-${var.env}-mobile"

  redirect_uris             = var.mobile.redirect_uris
  post_logout_redirect_uris = var.mobile.post_logout_redirect_uris

  app_type         = "OIDC_APP_TYPE_NATIVE"
  response_types   = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types      = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  access_token_type = "OIDC_TOKEN_TYPE_JWT"
  dev_mode          = var.dev_mode
}
