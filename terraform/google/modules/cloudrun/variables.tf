variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "region" {
  type = string
}

variable "repository_id" {
  type = string
  default = "langfuse-repo"
}

variable "langfuse_version" {
  type = string
}

variable "nextauth_secret" {
  type = string
}

variable "salt" {
  type = string
}

variable "encryption_key" {
  type = string
}

variable "telemetry_enabled" {
  type    = string
  default = "true"
}

variable "langfuse_enable_experimental_features" {
  type    = string
  default = "false"
}

variable "langfuse_init_org_id" {
  type    = string
  default = ""
}

variable "langfuse_init_org_name" {
  type    = string
  default = ""
}

variable "langfuse_init_project_id" {
  type    = string
  default = ""
}

variable "langfuse_init_project_name" {
  type    = string
  default = ""
}

variable "langfuse_init_project_public_key" {
  type    = string
  default = ""
}

variable "langfuse_init_project_secret_key" {
  type    = string
  default = ""
}

variable "langfuse_init_user_email" {
  type    = string
  default = ""
}

variable "langfuse_init_user_name" {
  type    = string
  default = ""
}

variable "langfuse_init_user_password" {
  type    = string
  default = ""
}

variable "postgres_user" {
  type = string
  default = "postgres"
}

variable "postgres_password" {
  type = string
  default = "postgres"
}

variable "postgres_db" {
  type = string
  default = "postgres"
}

variable "cloudsql_internal_ip" {
  type = string
}

variable "vpc_network_name" {
  type = string
}
