variable "name" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "web" {
  description = "Web/backend OIDC client"
  type = object({
    redirect_uris             = list(string)
    post_logout_redirect_uris = optional(list(string), [])
  })
  default = null
}

variable "mobile" {
  description = "Mobile OIDC client"
  type = object({
    redirect_uris             = list(string)
    post_logout_redirect_uris = optional(list(string), [])
  })
  default = null
}

variable "dev_mode" {
  description = "Allow http:// redirect URIs"
  type        = bool
}
