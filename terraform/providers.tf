terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }

  # Configure backend for state storage
  # This is commented out as it's typically configured in CI/CD
  # backend "gcs" {
  #   bucket = "terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
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
