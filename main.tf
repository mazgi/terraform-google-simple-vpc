provider "google" {}
provider "google-beta" {}

terraform {
  required_version = ">= 0.12.0"
  required_providers {
    google      = ">= 3.0.0"
    google-beta = ">= 3.0.0"
  }
}

