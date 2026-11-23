module "squadplay_dev" {
  source = "../../modules/project"

  name     = "squadplay"
  env      = "dev"
  dev_mode = true

  mobile = {
    redirect_uris             = ["com.squadplay.app:/callback"]
    post_logout_redirect_uris = ["com.squadplay.app:/logout"]
  }
}

output "squadplay_database_url" {
  value     = module.squadplay_dev.database_url
  sensitive = true
}

output "squadplay_mobile_client_id" {
  value = module.squadplay_dev.mobile_client_id
}

output "squadplay_zitadel_org_id" {
  value = module.squadplay_dev.zitadel_org_id
}
