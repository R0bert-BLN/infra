locals {
  keycloak_url = "http://auth.localhost"

  smtp = {
    host        = "mailpit"
    port        = 1025
    from_domain = "localhost"
  }
}
