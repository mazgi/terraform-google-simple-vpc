output "google_compute_network" {
  value = {
    main = google_compute_network.main,
  }
}

output "google_compute_address" {
  value = {
    for_router = google_compute_address.for_router,
  }
}

output "google_compute_subnetwork" {
  value = {
    main = google_compute_subnetwork.main,
  }
}

output "google_compute_firewall" {
  value = {
    ingress-allow-any                       = google_compute_firewall.ingress-allow-any,
    egress-allow-any                        = google_compute_firewall.egress-allow-any,
    ingress-allow-ssh-from-specific-ranges  = google_compute_firewall.ingress-allow-ssh-from-specific-ranges,
    ingress-allow-http-from-specific-ranges = google_compute_firewall.ingress-allow-http-from-specific-ranges,
  }
}
