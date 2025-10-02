locals {
  bucket_base      = lower("${var.project_id}-${var.google_storage_bucket_name}-${var.workspace_suffix}")
  bucket_sanitized = regexreplace(local.bucket_base, "[^a-z0-9-]", "-")
  bucket_compact   = regexreplace(local.bucket_sanitized, "-{2,}", "-")
  bucket_value     = trim(local.bucket_compact, "-") != "" ? trim(local.bucket_compact, "-") : lower("${var.project_id}-${var.workspace_suffix}")
  bucket_name      = regexreplace(
    substr(local.bucket_value, 0, min(63, length(local.bucket_value))),
    "-+$",
    ""
  )
  service_account_id = regexreplace(
    substr("dify-${var.workspace_suffix}-storage-sa", 0, min(30, length("dify-${var.workspace_suffix}-storage-sa"))),
    "-+$",
    ""
  )
}

resource "google_storage_bucket" "dify_storage" {
  force_destroy               = false
  location                    = upper(var.region)
  name                        = local.bucket_name
  project                     = var.project_id
  public_access_prevention    = "enforced"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  labels                      = var.workspace_labels
}

resource "google_service_account" "storage_admin" {
  account_id   = local.service_account_id
  display_name = "Storage Admin Service Account (${var.workspace_suffix})"
}

resource "google_storage_bucket_iam_member" "storage_admin" {
  bucket = google_storage_bucket.dify_storage.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.storage_admin.email}"
}

resource "google_service_account_key" "storage_admin_key" {
  service_account_id = google_service_account.storage_admin.id
}
