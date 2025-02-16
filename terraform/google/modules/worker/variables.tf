variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "worker_repository_id" {
  type = string
}

variable "langfuse_worker_version" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "env_worker" {
  type = map(string)
}