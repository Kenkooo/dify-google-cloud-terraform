variable "project_id" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "dify_version" {
  type    = string
  default = "latest"
}

variable "dify_sandbox_version" {
  type    = string
  default = null
}

variable "cloud_run_ingress" {
  type    = string
  default = null
}

variable "cloud_run_deletion_protection" {
  type    = bool
  default = null
}

variable "nginx_repository_id" {
  type    = string
  default = null
}

variable "web_repository_id" {
  type    = string
  default = null
}

variable "api_repository_id" {
  type    = string
  default = null
}

variable "plugin_daemon_repository_id" {
  type    = string
  default = null
}

variable "sandbox_repository_id" {
  type    = string
  default = null
}

variable "secret_key" {
  type    = string
  default = null
}

variable "db_username" {
  type    = string
  default = null
}

variable "db_password" {
  type    = string
  default = null
}

variable "db_port" {
  type    = string
  default = null
}

variable "db_database" {
  type    = string
  default = null
}

variable "db_database_plugin" {
  type    = string
  default = null
}

variable "db_deletion_protection" {
  type    = bool
  default = null
}

variable "storage_type" {
  type    = string
  default = null
}

variable "google_storage_bucket_name" {
  type    = string
  default = null
}

variable "vector_store" {
  type    = string
  default = null
}

variable "indexing_max_segmentation_tokens_length" {
  type    = number
  default = null
}

variable "plugin_daemon_key" {
  type    = string
  default = null
}

variable "plugin_dify_inner_api_key" {
  type    = string
  default = null
}

variable "min_instance_count" {
  type    = number
  default = null
}

variable "max_instance_count" {
  type    = number
  default = null
}
