resource "google_compute_network" "vpc" {
  name                    = local.vpc_network_name
  auto_create_subnetworks = false
  description             = "VPC network for ${var.environment} environment"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${local.vpc_network_name}-subnet"
  ip_cidr_range            = "10.2.0.0/16" # Main subnet range - 65,536 addresses
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
  address       = "10.60.0.0" # Cloud SQL private IP range - 65,536 addresses
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

# Private Connection for Datastream
resource "google_datastream_private_connection" "private_connection" {
  display_name          = "${local.name_prefix}-datastream-connection"
  location              = var.region
  private_connection_id = "${local.name_prefix}-datastream-connection"

  vpc_peering_config {
    vpc    = google_compute_network.vpc.id
    subnet = "192.168.30.0/29" # Datastream requires a /29 subnet (8 IPs)
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    service     = "datastream"
  }

  depends_on = [
    google_project_service.apis["datastream"],
    google_service_networking_connection.private_vpc_connection
  ]
}

# Firewall rule to allow Datastream to connect to database instances
resource "google_compute_firewall" "allow_datastream" {
  name        = "${local.name_prefix}-allow-datastream"
  network     = google_compute_network.vpc.id
  description = "Allow Datastream to connect to PostgreSQL instances"
  priority    = 1000 # Added priority (default is 1000)

  allow {
    protocol = "tcp"
    ports    = ["5432"] # PostgreSQL default port
  }

  # Optional: Add target tags if you want to target specific instances
  target_tags = ["postgresql-instance"]

  source_ranges = ["192.168.30.0/29"] # Datastream private connection subnet

  depends_on = [
    google_compute_network.vpc
  ]
}

# Optional: Add a firewall rule to allow internal communication within the VPC
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
    "10.2.0.0/16",    # Main subnet
    "10.60.0.0/16",   # Cloud SQL range
    "192.168.30.0/29" # Datastream range
  ]

  depends_on = [
    google_compute_network.vpc
  ]
}

resource "google_compute_instance" "sql_proxy" {
  name         = "sql-proxy"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id
  }

  metadata_startup_script = <<-EOF
    # Install Cloud SQL Auth proxy
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
    chmod +x /usr/local/bin/cloud_sql_proxy
    # Start the proxy
    /usr/local/bin/cloud_sql_proxy -instances=${google_sql_database_instance.postgres.connection_name}=tcp:5432 &
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}
