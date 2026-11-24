variable "name" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "keycloak_url" {
  description = "Public Keycloak URL used to build the issuer URL"
  type        = string
}

variable "smtp" {
  description = "Mail server shared by every realm in this environment. null = no emails"
  type = object({
    host        = string
    port        = optional(number, 25)
    from_domain = string
  })
  default = null
}

variable "database" {
  description = "Postgres role and database. null = the project has no database"
  type = object({
    connection_limit = optional(number, 20)
  })
  default = null
}

variable "auth" {
  description = "Keycloak realm and OIDC clients. null = the project has no login"
  type = object({
    display_name         = optional(string)
    registration_allowed = optional(bool, true)

    email_from      = optional(string)
    email_from_name = optional(string)

    web = optional(object({
      redirect_uris             = list(string)
      post_logout_redirect_uris = optional(list(string), [])
      web_origins               = optional(list(string), ["+"])
    }))

    mobile = optional(object({
      redirect_uris             = list(string)
      post_logout_redirect_uris = optional(list(string), [])
    }))
  })
  default = null
}
