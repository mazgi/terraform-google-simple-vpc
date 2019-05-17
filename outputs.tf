output "google_compute_network.main.self_link" {
  value = "${google_compute_network.main.self_link}"
}

output "google_compute_address.for_router" {
  value = "${
    zipmap(
      google_compute_address.for_router.*.address,
      google_compute_address.for_router.*.region
    )
  }"
}

output "google_compute_subnetwork.main.*.ip_cidr_range" {
  value = "${
    zipmap(
      google_compute_subnetwork.main.*.ip_cidr_range,
      google_compute_subnetwork.main.*.self_link
    )
  }"
}

output "google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags" {
  value = ["${google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags}"]
}

output "google_compute_firewall.ingress-allow-http-from-specific-ranges.target_tags" {
  value = ["${google_compute_firewall.ingress-allow-http-from-specific-ranges.target_tags}"]
}
