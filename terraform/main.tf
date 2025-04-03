provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_database_instance" "postgres" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = "sputter-database"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

output "instance_connection_name" {
  value       = google_sql_database_instance.postgres.connection_name
  description = "Connection name for client connections"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Name of the created database"
}
