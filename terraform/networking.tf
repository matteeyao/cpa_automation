# VPC Network
resource "google_compute_network" "vpc" {
  name                    = local.vpc_network_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.vpc_network_name}-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "${local.name_prefix}-secondary-range"
    ip_cidr_range = "192.168.20.0/24"
  }

  depends_on = [
    google_compute_network.vpc
  ]
}

# Private IP address range for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${local.vpc_network_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id

  depends_on = [
    google_compute_network.vpc
  ]
}

# VPC Network Peering for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [
    google_compute_global_address.private_ip_address
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Private Connection for Datastream
resource "google_datastream_private_connection" "private_connection" {
  display_name          = "${local.name_prefix}-datastream-connection"
  location              = var.region
  private_connection_id = "${local.name_prefix}-datastream-connection"

  vpc_peering_config {
    vpc    = google_compute_network.vpc.id
    subnet = "192.168.30.0/29"
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  depends_on = [
    google_project_service.apis["datastream"],
    google_service_networking_connection.private_vpc_connection
  ]
}
