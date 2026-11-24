terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    keycloak = {
      source = "keycloak/keycloak"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
