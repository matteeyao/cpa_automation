locals {
  required_apis = {
    bigquery             = "bigquery.googleapis.com"
    cloudsql             = "sqladmin.googleapis.com"
    compute              = "compute.googleapis.com"
    cloudresourcemanager = "cloudresourcemanager.googleapis.com"
    servicenetworking    = "servicenetworking.googleapis.com"
  }
}

resource "google_project_service" "apis" {
  for_each = local.required_apis

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}
