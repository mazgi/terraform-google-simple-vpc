# --------------------------------
# Terraform configuration

terraform {
  # https://www.terraform.io/downloads.html
  required_version = "0.15.5"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws         = "3.43.0"
    # https://registry.terraform.io/providers/hashicorp/google/latest
    google      = "3.70.0"
    google-beta = "3.70.0"
  }

  backend "gcs" {
    prefix = "default/terraform"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}
