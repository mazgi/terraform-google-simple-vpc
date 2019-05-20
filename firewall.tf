# --------------------------------
# Firewall rules
#
# naming: DIRECTION-{ALLOW,DENY}-PROTOCOL-{FROM,TO}-LOCATION

resource "google_compute_firewall" "ingress-allow-any" {
  direction = "INGRESS"
  name      = "${google_compute_network.main.name}-ingress-allow-any"
  network   = "${google_compute_network.main.self_link}"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "${google_compute_subnetwork.main.*.ip_cidr_range}",
  ]
}

resource "google_compute_firewall" "egress-allow-any" {
  direction = "EGRESS"
  name      = "${google_compute_network.main.name}-egress-allow-any"
  network   = "${google_compute_network.main.self_link}"

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
}

resource "google_compute_firewall" "ingress-allow-ssh-from-specific-ranges" {
  direction = "INGRESS"
  name      = "${google_compute_network.main.name}-ingress-allow-ssh-from-specific-ranges"
  network   = "${google_compute_network.main.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.cidr_blocks_allow_ssh}"]

  target_tags = [
    "firewall-allow-ssh-from-any",
  ]
}

resource "google_compute_firewall" "ingress-allow-http-from-specific-ranges" {
  direction = "INGRESS"
  name      = "${google_compute_network.main.name}-ingress-allow-http-from-specific-ranges"
  network   = "${google_compute_network.main.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["${var.cidr_blocks_allow_http}"]

  target_tags = [
    "firewall-allow-http-from-any",
  ]
}
