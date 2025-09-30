terraform {
  backend "gcs" {
    bucket = "your-tfstate-bucket" # replace with your bucket name
    prefix = "dify"
  }
}

provider "google" {
  project = local.config.project_id
  region  = local.config.region
}

provider "google-beta" {
  project = local.config.project_id
  region  = local.config.region
}