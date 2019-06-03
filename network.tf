# --------------------------------
# Compute Network and Subnetworks

resource "google_compute_network" "main" {
  name                    = var.basename
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  provider = "google-beta"

  count = length(keys(var.cidr_blocks_subnetworks))

  ip_cidr_range    = element(keys(var.cidr_blocks_subnetworks), count.index)
  name             = format("%s-%d", var.basename, count.index)
  network          = google_compute_network.main.self_link
  enable_flow_logs = true
  region           = lookup(var.cidr_blocks_subnetworks, element(keys(var.cidr_blocks_subnetworks), count.index))

  log_config {
    flow_sampling = var.flow_sampling
  }
}

# --------------------------------
# Routings

resource "google_compute_router" "this" {
  count = length(var.cidr_blocks_subnetworks)

  name    = format("%s-%d", var.basename, count.index)
  network = google_compute_network.main.self_link
  region  = lookup(var.cidr_blocks_subnetworks, element(keys(var.cidr_blocks_subnetworks), count.index))
}

resource "google_compute_address" "for_router" {
  count = length(var.cidr_blocks_subnetworks)

  name   = format("%s-%d", var.basename, count.index)
  region = lookup(var.cidr_blocks_subnetworks, element(keys(var.cidr_blocks_subnetworks), count.index))
}

resource "google_compute_router_nat" "main" {
  count = length(var.cidr_blocks_subnetworks)

  name                               = format("%s-%d", var.basename, count.index)
  router                             = element(google_compute_router.this[*].name, count.index)
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = element(google_compute_subnetwork.main[*].self_link, count.index)

    source_ip_ranges_to_nat = [
      "ALL_IP_RANGES",
    ]
  }

  nat_ips = [element(google_compute_address.for_router[*].self_link, count.index)]

  region = lookup(var.cidr_blocks_subnetworks, element(keys(var.cidr_blocks_subnetworks), count.index))
}
