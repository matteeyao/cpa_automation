resource "google_sql_database_instance" "postgres" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      private_network = var.vpc_network
    }
  }

  deletion_protection = false

  depends_on = [
    google_project_service.cloudsql
  ]
}

# Database
resource "google_sql_database" "database" {
  name     = "sputter-database"
  instance = google_sql_database_instance.postgres.name
}

# Database User
resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
