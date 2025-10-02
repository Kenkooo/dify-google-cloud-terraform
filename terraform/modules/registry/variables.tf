variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "workspace_labels" {
  type = map(string)
}

variable "nginx_repository_id" {
  type = string
}

variable "web_repository_id" {
  type = string
}

variable "api_repository_id" {
  type = string
}

variable "sandbox_repository_id" {
  type = string
}

variable "plugin_daemon_repository_id" {
  type = string
}
