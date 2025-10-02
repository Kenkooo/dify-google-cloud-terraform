variable "region" {
  type = string
}

variable "vpc_network_name" {
  type = string
}

variable "workspace_suffix" {
  type = string
}

variable "workspace_labels" {
  type = map(string)
}
