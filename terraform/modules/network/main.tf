locals {
  vpc_name = trim(
    substr("dify-${var.workspace_suffix}-vpc", 0, min(63, length("dify-${var.workspace_suffix}-vpc"))),
    "-"
  )
  subnet_name = trim(
    substr("dify-${var.workspace_suffix}-subnet", 0, min(63, length("dify-${var.workspace_suffix}-subnet"))),
    "-"
  )
  firewall_name = trim(
    substr("dify-${var.workspace_suffix}-allow-http-https", 0, min(63, length("dify-${var.workspace_suffix}-allow-http-https"))),
    "-"
  )
  router_name = trim(
    substr("dify-${var.workspace_suffix}-nat-router", 0, min(63, length("dify-${var.workspace_suffix}-nat-router"))),
    "-"
  )
  router_nat_name = trim(
    substr("dify-${var.workspace_suffix}-nat", 0, min(63, length("dify-${var.workspace_suffix}-nat"))),
    "-"
  )
}

resource "google_compute_network" "dify_vpc" {
  name                    = local.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Dify network for workspace ${var.workspace_suffix}"
}

resource "google_compute_subnetwork" "dify_subnet" {
  name          = local.subnet_name
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.dify_vpc.id
}

resource "google_compute_firewall" "allow_http_https" {
  name    = local.firewall_name
  network = google_compute_network.dify_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  direction = "EGRESS"
  priority  = 1000

  destination_ranges = ["0.0.0.0/0"]

  target_tags = [local.firewall_name]
}

resource "google_compute_router" "router" {
  name    = local.router_name
  network = google_compute_network.dify_vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name   = local.router_nat_name
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
