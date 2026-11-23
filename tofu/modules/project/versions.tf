terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    zitadel = {
      source = "zitadel/zitadel"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
