# Google Cloud Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Random ID for unique resource naming
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Cloud SQL instance
resource "google_sql_database_instance" "payroll_db" {
  name             = "payroll-db-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier              = "db-f1-micro"
    disk_autoresize   = true
    disk_type         = "PD_SSD"  # Explicit disk type
    availability_type = "ZONAL"

    backup_configuration {
      enabled            = true
      start_time         = "03:00"  # Scheduled backup time (UTC)
      location           = "us"     # Backup location
      point_in_time_recovery_enabled = true  # Enable PITR
    }

    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true  # Enforce SSL connections
    }
  }

  # Ensure instance is deleted cleanly
  deletion_protection = false  # Set to true in production
}

# Database configuration
resource "google_sql_database" "payroll_service" {
  name     = "payroll-service"  # Hyphen preferred over underscore
  instance = google_sql_database_instance.payroll_db.name

  depends_on = [google_sql_database_instance.payroll_db]
}

# Database admin user
resource "google_sql_user" "admin" {
  name     = "payroll-admin"  # Hyphen preferred over underscore
  instance = google_sql_database_instance.payroll_db.name
  password = var.db_password

  depends_on = [google_sql_database_instance.payroll_db]
}

# Outputs for reference
output "instance_connection_name" {
  value       = google_sql_database_instance.payroll_db.connection_name
  description = "Connection name for client connections"
}

output "database_name" {
  value       = google_sql_database.payroll_service.name
  description = "Name of the created database"
}
