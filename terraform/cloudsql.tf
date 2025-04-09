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

  deletion_protection = var.environment == "prod" ? true : false

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

resource "google_sql_user" "datastream_user" {
  name     = "datastream_user"
  instance = google_sql_database_instance.postgres.name
  password = var.datastream_password
}

resource "null_resource" "setup_postgres_replication" {
  depends_on = [google_sql_database_instance.postgres, google_sql_user.datastream_user]

  provisioner "local-exec" {
    command = <<-EOT
      # Connect to the database and set up replication
      PGPASSWORD=${google_sql_user.datastream_user.password} psql -h ${google_compute_instance.sql_proxy.network_interface[0].network_ip} -U ${google_sql_user.datastream_user.name} -d ${google_sql_database.database.name} -c "ALTER USER ${google_sql_user.datastream_user.name} WITH REPLICATION;"
      PGPASSWORD=${google_sql_user.datastream_user.password} psql -h ${google_compute_instance.sql_proxy.network_interface[0].network_ip} -U ${google_sql_user.datastream_user.name} -d ${google_sql_database.database.name} -c "CREATE PUBLICATION datastream_publication FOR ALL TABLES;"
      PGPASSWORD=${google_sql_user.datastream_user.password} psql -h ${google_compute_instance.sql_proxy.network_interface[0].network_ip} -U ${google_sql_user.datastream_user.name} -d ${google_sql_database.database.name} -c "SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('datastream_replication_slot', 'pgoutput');"
    EOT
  }
}
