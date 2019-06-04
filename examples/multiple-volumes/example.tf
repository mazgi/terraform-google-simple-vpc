# --------------------------------
# Google Cloud VPC Network configuration

module "multiple-volumes-google-vpc" {
  #source = "mazgi/simple-vpc/google"
  source = "../../"

  basename = "multiple-volumes"

  cidr_blocks_allow_ssh = [
    "192.0.2.0/24",              # Your specific IP address range
    var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`.
  ]
}

# --------------------------------
# Google Compute Engine instance configuration

resource "google_filestore_instance" "standard" {
  name = "standard"
  zone = "us-central1-a"
  tier = "STANDARD"

  file_shares {
    capacity_gb = 1024
    name        = "default"
  }

  networks {
    network = module.multiple-volumes-google-vpc.google_compute_network.main.name
    modes   = ["MODE_IPV4"]
  }
}

resource "google_filestore_instance" "premium" {
  name = "premium"
  zone = "us-central1-a"
  tier = "PREMIUM"

  file_shares {
    capacity_gb = 2560
    name        = "default"
  }

  networks {
    network = module.multiple-volumes-google-vpc.google_compute_network.main.name
    modes   = ["MODE_IPV4"]
  }
}

# --------------------------------
# Google Compute Engine instance configuration

resource "google_compute_disk" "multiple-volumes-pd-ssd" {
  count = 2

  name = format("multiple-volumes-pd-ssd-%02d", count.index + 1)
  type = "pd-ssd"
  zone = "us-central1-a"
  size = 500
}

resource "google_compute_disk" "multiple-volumes-pd-standard" {
  count = 2

  name = format("multiple-volumes-pd-standard-%02d", count.index + 1)
  type = "pd-standard"
  zone = "us-central1-a"
  size = 500
}

resource "google_compute_instance" "multiple-volumes-instance" {
  count = 2

  name         = format("instance-%02d", count.index + 1)
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      size  = 100
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  attached_disk {
    source = google_compute_disk.multiple-volumes-pd-ssd[count.index].self_link
  }

  attached_disk {
    source = google_compute_disk.multiple-volumes-pd-standard[count.index].self_link
  }

  // NOTE: The `network` is cannot work if you using "custom subnetmode network", you should set the `subnetwork` instead of the `network`.
  //       For example, the following error has occurred:
  // --------
  // Error: Error creating instance: googleapi: Error 400: Invalid value for field 'resource.networkInterfaces[0]': '{  "network": "projects/****/global/networks/****",  "accessConfig": [{    "t...'. Subnetwork should be specified for custom subnetmode network, invalid
  network_interface {
    #network = module.multiple-volumes-google-vpc.google_compute_network.main.self_link
    subnetwork = module.multiple-volumes-google-vpc.google_compute_subnetwork.main[0].self_link
    access_config {}
  }

  tags = concat(
    module.multiple-volumes-google-vpc.google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags[*],
  )

  metadata_startup_script = <<-EOF
  #!/bin/bash -eu
  curl -L github.com/mazgi.keys > /home/hidenori.matsuki/.ssh/authorized_keys2
  EOF
}
