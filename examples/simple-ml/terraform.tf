# --------------------------------
# Terraform configuration

terraform {
  required_version = "0.11.14"

  required_providers {
    google      = "2.6"
    google-beta = "2.6"
  }

  backend "gcs" {
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = "${file("gcp-service-account-key.json")}"
  project     = "${var.gcp_project_id}"
  region      = "us-central1"
}

provider "google-beta" {
  credentials = "${file("gcp-service-account-key.json")}"
  project     = "${var.gcp_project_id}"
  region      = "us-central1"
}
