variable "name" {
  description = "Name of both the role and the database"
  type        = string
}

variable "connection_limit" {
  description = "Max connections for the role"
  type        = number
}
