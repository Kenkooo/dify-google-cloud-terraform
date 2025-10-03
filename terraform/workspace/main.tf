locals {
  workspace_name = terraform.workspace

  normalization_allowed_chars = toset(concat(
    split(",", "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"),
    split(",", "0,1,2,3,4,5,6,7,8,9"),
    ["-"]
  ))

  workspace_base     = lower("ws-${local.workspace_name}")
  workspace_replaced = replace(local.workspace_base, "_", "-")
  workspace_chars = [
    for idx in range(length(local.workspace_replaced)) : substr(local.workspace_replaced, idx, 1)
  ]
  workspace_normalized_chars = [
    for ch in local.workspace_chars : contains(local.normalization_allowed_chars, ch) ? ch : "-"
  ]
  workspace_compact_chars = [
    for idx, ch in local.workspace_normalized_chars :
    idx == 0 ? ch : (ch == "-" && local.workspace_normalized_chars[idx - 1] == "-" ? "" : ch)
  ]
  workspace_compact = join("", local.workspace_compact_chars)
  workspace_trimmed = trim(local.workspace_compact, "-")
  workspace_value   = workspace_trimmed != "" ? workspace_trimmed : "ws"
  workspace_suffix  = substr(local.workspace_value, 0, min(63, length(local.workspace_value)))
  workspace_labels = {
    workspace = local.workspace_suffix
  }

  workspace_supported_files = [
    for ext in ["tfvars.json", "tfvars.yaml", "tfvars.yml"] :
    "workspaces/${local.workspace_name}.${ext}"
  ]

  workspace_file_candidates = flatten([
    [
      for rel_path in local.workspace_supported_files :
      "${path.module}/${rel_path}"
      if fileexists("${path.module}/${rel_path}")
    ]
  ])

  workspace_file         = length(local.workspace_file_candidates) > 0 ? local.workspace_file_candidates[0] : null
  workspace_exists       = local.workspace_file != null
  workspace_file_ext     = local.workspace_exists ? lower(element(reverse(split(".", local.workspace_file)), 0)) : ""
  workspace_data         = local.workspace_exists ? local.decode_workspace_file : {}
  decode_workspace_file  = local.workspace_file_ext == "json" ? jsondecode(file(local.workspace_file)) : yamldecode(file(local.workspace_file))

  override_map = {
    project_id                              = var.project_id
    region                                  = var.region
    dify_version                            = var.dify_version
    dify_plugin_daemon_version              = var.dify_plugin_daemon_version
    dify_sandbox_version                    = var.dify_sandbox_version
    nginx_repository_id                     = var.nginx_repository_id
    web_repository_id                       = var.web_repository_id
    api_repository_id                       = var.api_repository_id
    plugin_daemon_repository_id             = var.plugin_daemon_repository_id
    sandbox_repository_id                   = var.sandbox_repository_id
    secret_key                              = var.secret_key
    db_username                             = var.db_username
    db_password                             = var.db_password
    db_port                                 = var.db_port
    db_database                             = var.db_database
    db_database_plugin                      = var.db_database_plugin
    db_deletion_protection                  = var.db_deletion_protection
    storage_type                            = var.storage_type
    google_storage_bucket_name              = var.google_storage_bucket_name
    vector_store                            = var.vector_store
    indexing_max_segmentation_tokens_length = var.indexing_max_segmentation_tokens_length
    cloud_run_ingress                       = var.cloud_run_ingress
    plugin_daemon_key                       = var.plugin_daemon_key
    plugin_dify_inner_api_key               = var.plugin_dify_inner_api_key
    min_instance_count                      = var.min_instance_count
    max_instance_count                      = var.max_instance_count
  }

  config = merge(
    local.workspace_data,
    { for key, value in local.override_map : key => value if value != null }
  )

  required_keys = [
    "project_id",
    "region",
    "dify_version",
    "dify_plugin_daemon_version",
    "dify_sandbox_version",
    "nginx_repository_id",
    "web_repository_id",
    "api_repository_id",
    "plugin_daemon_repository_id",
    "sandbox_repository_id",
    "secret_key",
    "db_username",
    "db_password",
    "db_port",
    "db_database",
    "db_database_plugin",
    "db_deletion_protection",
    "storage_type",
    "google_storage_bucket_name",
    "vector_store",
    "indexing_max_segmentation_tokens_length",
    "cloud_run_ingress",
    "plugin_daemon_key",
    "plugin_dify_inner_api_key",
    "min_instance_count",
    "max_instance_count",
  ]

  missing_required_keys = [
    for key in local.required_keys : key
    if try(local.config[key], null) == null
  ]

  shared_env_vars = {
    "SECRET_KEY"                                 = local.config.secret_key
    "LOG_LEVEL"                                  = "INFO"
    "CONSOLE_WEB_URL"                            = ""
    "CONSOLE_API_URL"                            = ""
    "SERVICE_API_URL"                            = ""
    "APP_WEB_URL"                                = ""
    "CHECK_UPDATE_URL"                           = "https://updates.dify.ai"
    "OPENAI_API_BASE"                            = "https://api.openai.com/v1"
    "FILES_URL"                                  = ""
    "MIGRATION_ENABLED"                          = "true"
    "CELERY_BROKER_URL"                          = "redis://${module.redis.redis_host}:${module.redis.redis_port}/1"
    "WEB_API_CORS_ALLOW_ORIGINS"                 = "*"
    "CONSOLE_CORS_ALLOW_ORIGINS"                 = "*"
    "DB_USERNAME"                                = local.config.db_username
    "DB_PASSWORD"                                = local.config.db_password
    "DB_HOST"                                    = module.cloudsql.cloudsql_internal_ip
    "DB_PORT"                                    = local.config.db_port
    "STORAGE_TYPE"                               = local.config.storage_type
    "GOOGLE_STORAGE_BUCKET_NAME"                 = module.storage.storage_bucket_name
    "GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64" = module.storage.storage_admin_key_base64
    "REDIS_HOST"                                 = module.redis.redis_host
    "REDIS_PORT"                                 = module.redis.redis_port
    "VECTOR_STORE"                               = local.config.vector_store
    "PGVECTOR_HOST"                              = module.cloudsql.cloudsql_internal_ip
    "PGVECTOR_PORT"                              = "5432"
    "PGVECTOR_USER"                              = local.config.db_username
    "PGVECTOR_PASSWORD"                          = local.config.db_password
    "PGVECTOR_DATABASE"                          = local.config.db_database
    "CODE_EXECUTION_ENDPOINT"                    = module.cloudrun.dify_sandbox_url
    "CODE_EXECUTION_API_KEY"                     = "dify-sandbox"
    "INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH"    = local.config.indexing_max_segmentation_tokens_length
    "PLUGIN_DAEMON_KEY"                          = local.config.plugin_daemon_key
    "PLUGIN_DIFY_INNER_API_KEY"                  = local.config.plugin_dify_inner_api_key
  }
}

check "workspace_file_exists" {
  assert {
    condition     = local.workspace_exists
    error_message = "Workspace configuration file not found for workspace '${local.workspace_name}'. Provide one of: ${join(", ", local.workspace_supported_files)}"
  }
}

check "workspace_file_unique" {
  assert {
    condition     = length(local.workspace_file_candidates) <= 1
    error_message = "Multiple workspace configuration files found for workspace '${local.workspace_name}'. Keep only one of: ${join(", ", local.workspace_supported_files)}"
  }
}

check "workspace_required_values" {
  assert {
    condition     = length(local.missing_required_keys) == 0
    error_message = "Workspace configuration '${local.workspace_file}' is missing required values: ${join(", ", local.missing_required_keys)}"
  }
}

module "cloudrun" {
  source = "../modules/cloudrun"

  project_id                  = local.config.project_id
  region                      = local.config.region
  workspace_suffix            = local.workspace_suffix
  workspace_labels            = local.workspace_labels
  dify_version                = local.config.dify_version
  dify_sandbox_version        = local.config.dify_sandbox_version
  cloud_run_ingress           = local.config.cloud_run_ingress
  nginx_repository_id         = local.config.nginx_repository_id
  web_repository_id           = local.config.web_repository_id
  api_repository_id           = local.config.api_repository_id
  sandbox_repository_id       = local.config.sandbox_repository_id
  vpc_network_name            = module.network.vpc_network_name
  vpc_subnet_name             = module.network.vpc_subnet_name
  plugin_daemon_repository_id = local.config.plugin_daemon_repository_id
  plugin_daemon_key           = local.config.plugin_daemon_key
  plugin_dify_inner_api_key   = local.config.plugin_dify_inner_api_key
  dify_plugin_daemon_version  = local.config.dify_plugin_daemon_version
  db_database                 = local.config.db_database
  db_database_plugin          = local.config.db_database_plugin
  filestore_ip_address        = module.filestore.filestore_ip_address
  filestore_fileshare_name    = module.filestore.filestore_fileshare_name
  shared_env_vars             = local.shared_env_vars
  min_instance_count          = local.config.min_instance_count
  max_instance_count          = local.config.max_instance_count

  depends_on = [google_project_service.enabled_services]
}

module "cloudsql" {
  source = "../modules/cloudsql"

  project_id          = local.config.project_id
  region              = local.config.region
  workspace_suffix    = local.workspace_suffix
  workspace_labels    = local.workspace_labels
  db_username         = local.config.db_username
  db_password         = local.config.db_password
  deletion_protection = local.config.db_deletion_protection

  vpc_network_name = module.network.vpc_network_name

  depends_on = [google_project_service.enabled_services]
}

module "redis" {
  source = "../modules/redis"

  project_id = local.config.project_id
  region     = local.config.region
  workspace_suffix = local.workspace_suffix
  workspace_labels = local.workspace_labels

  vpc_network_name = module.network.vpc_network_name

  depends_on = [google_project_service.enabled_services]
}

module "network" {
  source = "../modules/network"

  project_id = local.config.project_id
  region     = local.config.region
  workspace_suffix = local.workspace_suffix

  depends_on = [google_project_service.enabled_services]
}

module "storage" {
  source = "../modules/storage"

  project_id                 = local.config.project_id
  region                     = local.config.region
  workspace_suffix           = local.workspace_suffix
  workspace_labels           = local.workspace_labels
  google_storage_bucket_name = local.config.google_storage_bucket_name

  depends_on = [google_project_service.enabled_services]
}

module "filestore" {
  source = "../modules/filestore"

  region           = local.config.region
  workspace_suffix = local.workspace_suffix
  workspace_labels = local.workspace_labels

  vpc_network_name = module.network.vpc_network_name

  depends_on = [google_project_service.enabled_services]
}

module "registry" {
  source = "../modules/registry"

  project_id                  = local.config.project_id
  region                      = local.config.region
  workspace_labels            = local.workspace_labels
  nginx_repository_id         = local.config.nginx_repository_id
  web_repository_id           = local.config.web_repository_id
  api_repository_id           = local.config.api_repository_id
  sandbox_repository_id       = local.config.sandbox_repository_id
  plugin_daemon_repository_id = local.config.plugin_daemon_repository_id

  depends_on = [google_project_service.enabled_services]
}

locals {
  services = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "redis.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "enabled_services" {
  for_each = toset(local.services)
  project  = local.config.project_id
  service  = each.value
}
