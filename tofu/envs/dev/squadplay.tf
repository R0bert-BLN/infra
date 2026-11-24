module "squadplay_dev" {
  source = "../../modules/project"

  name         = "squadplay"
  env          = "dev"
  keycloak_url = local.keycloak_url
  smtp         = local.smtp

  database = {}

  auth = {
    display_name = "SquadPlay"

    mobile = {
      redirect_uris             = ["com.squadplay.app:/callback"]
      post_logout_redirect_uris = ["com.squadplay.app:/logout"]
    }
  }
}

output "squadplay_database_url" {
  value     = module.squadplay_dev.database_url
  sensitive = true
}

output "squadplay_issuer_url" {
  value = module.squadplay_dev.issuer_url
}

output "squadplay_mobile_client_id" {
  value = module.squadplay_dev.mobile_client_id
}
