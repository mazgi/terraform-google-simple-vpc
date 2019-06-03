# --------------------------------
# Firewall rules
#
# naming: DIRECTION-{ALLOW,DENY}-PROTOCOL-{FROM,TO}-LOCATION

resource "google_compute_firewall" "ingress-allow-any" {
  direction = "INGRESS"
  name      = format("%s-ingress-allow-any", google_compute_network.main.name)
  network   = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = google_compute_subnetwork.main[*].ip_cidr_range

  target_tags = [
    "firewall-ingress-allow-any",
  ]
}

resource "google_compute_firewall" "egress-allow-any" {
  direction = "EGRESS"
  name      = format("%s-egress-allow-any", google_compute_network.main.name)
  network   = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  destination_ranges = [
    "0.0.0.0/0",
  ]

  target_tags = [
    "firewall-egress-allow-any",
  ]
}

resource "google_compute_firewall" "ingress-allow-ssh-from-specific-ranges" {
  direction = "INGRESS"
  name      = format("%s-ingress-allow-ssh-from-specific-ranges", google_compute_network.main.name)
  network   = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.cidr_blocks_allow_ssh

  target_tags = [
    "firewall-ingress-allow-ssh-from-specific-ranges",
  ]
}

resource "google_compute_firewall" "ingress-allow-http-from-specific-ranges" {
  direction = "INGRESS"
  name      = format("%s-ingress-allow-http-from-specific-ranges", google_compute_network.main.name)
  network   = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.cidr_blocks_allow_http

  target_tags = [
    "firewall-ingress-allow-http-from-specific-ranges",
  ]
}
