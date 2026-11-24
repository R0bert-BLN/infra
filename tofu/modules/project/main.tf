locals {
  db_name      = "${var.name}_${var.env}"
  realm        = "${var.name}_${var.env}"
  display_name = coalesce(try(var.auth.display_name, null), var.name)
}

module "database" {
  source = "../database"
  count  = var.database == null ? 0 : 1

  name             = local.db_name
  connection_limit = var.database.connection_limit
}

module "auth" {
  source = "../auth"
  count  = var.auth == null ? 0 : 1

  realm                = local.realm
  display_name         = local.display_name
  registration_allowed = var.auth.registration_allowed
  web                  = var.auth.web
  mobile               = var.auth.mobile

  smtp = var.smtp == null ? null : {
    host              = var.smtp.host
    port              = var.smtp.port
    from              = coalesce(var.auth.email_from, "noreply@${var.name}.${var.smtp.from_domain}")
    from_display_name = coalesce(var.auth.email_from_name, local.display_name)
  }
}
