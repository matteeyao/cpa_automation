resource "google_compute_network" "vpc" {
  name                    = local.vpc_network_name
  auto_create_subnetworks = false
  description             = "VPC network for ${var.environment} environment"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${local.vpc_network_name}-subnet"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  description              = "Primary subnet for ${var.environment} environment"

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
  address       = "10.60.0.0"
  description   = "Private IP range for Cloud SQL instances"

  depends_on = [
    google_compute_network.vpc
  ]
}

# VPC Network Peering for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  deletion_policy         = "ABANDON"

  depends_on = [
    google_compute_global_address.private_ip_address
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Basic firewall rule to allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name        = "${local.name_prefix}-allow-internal"
  network     = google_compute_network.vpc.id
  description = "Allow internal communication between resources in the VPC"
  priority    = 1000

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.2.0.0/16", # Main subnet
    "10.60.0.0/16" # Cloud SQL range
  ]

  depends_on = [
    google_compute_network.vpc
  ]
}
