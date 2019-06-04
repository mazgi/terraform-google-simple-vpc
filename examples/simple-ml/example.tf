# --------------------------------
# Google Cloud VPC Network configuration

module "simple-ml-google-vpc" {
  #source = "mazgi/simple-vpc/google"
  source = "../../"

  basename = "simple-ml"

  cidr_blocks_allow_ssh = [
    "192.0.2.0/24",              # Your specific IP address range
    var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`.
  ]
}


# --------------------------------
# Addtional firewall rules for Jupyter Notebook

resource "google_compute_firewall" "ingress-allow-jupyternotebook-from-specific-ranges" {
  direction = "INGRESS"
  name      = "ingress-allow-http-from-specific-ranges"
  network   = module.simple-ml-google-vpc.google_compute_network.main.self_link

  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }

  source_ranges = [
    "192.0.2.0/24",              # Your specific IP address range
    var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`.
  ]

  target_tags = [
    "firewall-ingress-allow-jupyternotebook-from-specific-ranges",
  ]
}

# --------------------------------
# Google Compute Engine instance configuration

resource "google_compute_instance" "simple-ml-gpu-instance-1" {
  #provider = "google-beta"

  name         = "gpu-instance-1"
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "deeplearning-platform-release/common-cu100"
    }
  }

  guest_accelerator {
    type  = "nvidia-tesla-v100"
    count = 1
  }

  # see:
  # - https://www.terraform.io/docs/providers/google/r/compute_instance.html#guest_accelerator
  # - https://cloud.google.com/compute/docs/gpus/
  scheduling {
    # NOTE: GPU instances cannot live migrate and must terminate for host maintenance events.
    on_host_maintenance = "TERMINATE"
  }

  // NOTE: The `network` is cannot work if you using "custom subnetmode network", you should set the `subnetwork` instead of the `network`.
  //       For example, the following error has occurred:
  // --------
  // Error: Error creating instance: googleapi: Error 400: Invalid value for field 'resource.networkInterfaces[0]': '{  "network": "projects/****/global/networks/simple-ml",  "accessConfig": [{    "t...'. Subnetwork should be specified for custom subnetmode network, invalid
  network_interface {
    #network = module.simple-ml-google-vpc.google_compute_network.main.self_link
    subnetwork = module.simple-ml-google-vpc.google_compute_subnetwork.main[0].self_link
    access_config {}
  }

  tags = concat(
    module.simple-ml-google-vpc.google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags[*],
    google_compute_firewall.ingress-allow-jupyternotebook-from-specific-ranges.target_tags[*],
  )

  #metadata_startup_script = <<-EOF
  ##!/bin/bash -eu
  #curl -L github.com/mazgi.keys > /home/hidenori_matsuki/.ssh/authorized_keys2
  #EOF
}

