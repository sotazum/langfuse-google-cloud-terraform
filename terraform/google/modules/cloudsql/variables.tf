variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "postgres_user" {
  type    = string
  default = "postgres"
}

variable "postgres_password" {
  type    = string
  default = "postgres"
}

variable "postgres_db" {
  type    = string
  default = "postgres"
}

variable "vpc_network_name" {
  type = string
}
