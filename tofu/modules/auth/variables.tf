variable "realm" {
  description = "Realm name"
  type        = string
}

variable "display_name" {
  description = "Name shown on the login page"
  type        = string
}

variable "registration_allowed" {
  description = "Show the Register link on the login page"
  type        = bool
}

variable "smtp" {
  description = "Mail server for verification and password reset emails"
  type = object({
    host              = string
    port              = number
    from              = string
    from_display_name = string
  })
}

variable "web" {
  description = "Confidential client for a backend or a server-rendered site"
  type = object({
    redirect_uris             = list(string)
    post_logout_redirect_uris = list(string)
    web_origins               = list(string)
  })
}

variable "mobile" {
  description = "Public client for a mobile app (PKCE, no secret)"
  type = object({
    redirect_uris             = list(string)
    post_logout_redirect_uris = list(string)
  })
}
