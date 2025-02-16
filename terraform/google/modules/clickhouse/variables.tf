variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "clickhouse_repository_id" {
  type = string
}

variable "clickhouse_version" {
  type = string
}

variable "env_clickhouse" {
  type = map(string)
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}
