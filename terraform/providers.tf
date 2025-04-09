terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.25.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Beta provider for features not yet in GA
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
