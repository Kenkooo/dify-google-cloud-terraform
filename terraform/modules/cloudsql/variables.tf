variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "workspace_suffix" {
  type = string
}

variable "workspace_labels" {
  type = map(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "vpc_network_name" {
  type = string
}

variable "deletion_protection" {
  type = bool
}
