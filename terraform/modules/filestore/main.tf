locals {
  filestore_name = regexreplace(
    substr("dify-${var.workspace_suffix}-filestore", 0, min(63, length("dify-${var.workspace_suffix}-filestore"))),
    "-+$",
    ""
  )
}

resource "google_filestore_instance" "default" {
  name     = local.filestore_name
  location = "${var.region}-b"
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"
  }

  networks {
    network = var.vpc_network_name
    modes   = ["MODE_IPV4"]
  }

  labels = var.workspace_labels
}