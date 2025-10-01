# Template for Terraform workspace configuration.
# Update the placeholder values before applying Terraform.

# Google Cloud project where Dify resources will be created.
project_id = "your-project-id"

# Region for Cloud Run, Artifact Registry, and other regional resources (e.g. asia-northeast1).
region = "your-region"

# Container image tags pushed to Artifact Registry.
dify_version               = "1.0.0"
dify_plugin_daemon_version = "1.0.0"
dify_sandbox_version       = "1.0.0"

# Cloud Run ingress control: all | internal | internal-and-cloud-load-balancing
cloud_run_ingress = "all"

# Artifact Registry repository IDs used by each service image.
nginx_repository_id          = "dify-nginx"
web_repository_id            = "dify-web"
api_repository_id            = "dify-api"
plugin_daemon_repository_id  = "dify-plugin-daemon"
sandbox_repository_id        = "dify-sandbox"

# Django SECRET_KEY value. Generate a long random string.
secret_key = "replace-with-strong-secret"

# Cloud SQL connection configuration.
db_username             = "dify"
db_password             = "replace-with-db-password"
db_port                 = "5432"
db_database             = "dify"
db_database_plugin      = "dify_plugin"
db_deletion_protection  = true

# Cloud Storage bucket for document uploads and other assets.
storage_type                 = "gcs"
google_storage_bucket_name  = "your-dify-storage-bucket"

# Vector store backend configuration.
vector_store                              = "pgvector"
indexing_max_segmentation_tokens_length   = 8000

# Shared secrets for the plugin daemon.
plugin_daemon_key          = "replace-with-plugin-daemon-key"
plugin_dify_inner_api_key  = "replace-with-plugin-inner-api-key"

# Cloud Run autoscaling bounds.
min_instance_count = 0
max_instance_count = 3
