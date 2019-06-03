provider "google" {}
provider "google-beta" {}

terraform {
  required_version = ">= 0.12.0"
  required_providers {
    google      = ">= 2.7.0"
    google-beta = ">= 2.7.0"
  }
}

