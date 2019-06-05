output "google_compute_instance-multiple-volumes-instances" {
  value = {
    for instance in google_compute_instance.multiple-volumes-instance :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "google_filestore_instance-standard" {
  value = google_filestore_instance.standard.networks[*].ip_addresses
}

output "google_filestore_instance-premium" {
  value = google_filestore_instance.premium.networks[*].ip_addresses
}
