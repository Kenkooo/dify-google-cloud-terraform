locals {
  redis_instance_name = regexreplace(
    substr("dify-${var.workspace_suffix}-redis", 0, min(63, length("dify-${var.workspace_suffix}-redis"))),
    "-+$",
    ""
  )
}

resource "google_redis_instance" "dify_redis" {
  name              = local.redis_instance_name
  tier              = "STANDARD_HA"
  memory_size_gb    = 1
  region            = var.region
  project           = var.project_id
  redis_version     = "REDIS_6_X"
  reserved_ip_range = "10.0.1.0/29"

  labels = var.workspace_labels

  authorized_network = var.vpc_network_name
}
