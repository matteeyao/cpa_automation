resource "google_sql_database_instance" "postgres" {
  name             = local.cloud_sql_instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
      }
    }

    ip_configuration {
      private_network = google_compute_network.vpc.id
      # Enable private IP
      ipv4_enabled = false
      ssl_mode     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3 # 3 AM
      update_track = "stable"
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [
    google_project_service.apis["cloudsql"],
    google_project_service.apis["servicenetworking"],
    google_project_service.apis["compute"],
    google_service_networking_connection.private_vpc_connection
  ]
}

# Database
resource "google_sql_database" "database" {
  name     = "payroll-database"
  instance = google_sql_database_instance.postgres.name
}

# Database User
resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
