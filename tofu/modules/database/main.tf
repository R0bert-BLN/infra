resource "random_password" "this" {
  length  = 32
  special = false
}

resource "postgresql_role" "this" {
  name             = var.name
  login            = true
  password         = random_password.this.result
  connection_limit = var.connection_limit
}

resource "postgresql_database" "this" {
  name  = var.name
  owner = postgresql_role.this.name
}

resource "postgresql_grant" "revoke_public" {
  database    = postgresql_database.this.name
  role        = "public"
  object_type = "database"
  privileges  = []
}
