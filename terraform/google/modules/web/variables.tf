variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "web_repository_id" {
  type = string
}

variable "langfuse_version" {
  type = string
}

variable "env_web" {
  type = map(string)
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}