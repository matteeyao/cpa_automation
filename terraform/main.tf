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

# Enable required APIs
resource "google_project_service" "datastream" {
  service            = "datastream.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

# Create BigQuery dataset
resource "google_bigquery_dataset" "payroll_dataset" {
  dataset_id    = "payroll_analytics"
  friendly_name = "Payroll Analytics Dataset"
  description   = "Dataset for payroll analytics data"
  location      = var.region
}

# Create Datastream connection profile for PostgreSQL
resource "google_datastream_connection_profile" "postgres_profile" {
  display_name          = "postgres-connection-profile"
  location              = var.region
  connection_profile_id = "postgres-profile"

  postgresql_profile {
    hostname = google_sql_database_instance.postgres.private_ip_address
    port     = 5432
    username = google_sql_user.user.name
    password = var.db_password
    database = google_sql_database.database.name
  }
}

# Create Datastream connection profile for BigQuery
resource "google_datastream_connection_profile" "bigquery_profile" {
  display_name          = "bigquery-connection-profile"
  location              = var.region
  connection_profile_id = "bigquery-profile"

  bigquery_profile {}
}

# Create Datastream stream
resource "google_datastream_stream" "postgres_to_bigquery" {
  display_name = "postgres-to-bigquery-stream"
  location     = var.region
  stream_id    = "postgres-to-bigquery"

  source_config {
    source_connection_profile = google_datastream_connection_profile.postgres_profile.id
    postgresql_source_config {
      include_objects {
        postgresql_schemas {
          schema = "public"
          postgresql_tables {
            table = "cpa_firms"
          }
          postgresql_tables {
            table = "businesses"
          }
          postgresql_tables {
            table = "employees"
          }
          postgresql_tables {
            table = "pay_periods"
          }
          postgresql_tables {
            table = "payroll_records"
          }
          postgresql_tables {
            table = "deductions"
          }
          postgresql_tables {
            table = "taxes"
          }
        }
      }
      max_concurrent_backfill_tasks = 1
      publication                   = "datastream_publication"
      replication_slot              = "datastream_replication_slot"
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery_profile.id
    bigquery_destination_config {
      data_freshness = "900s" # 15 minutes
      source_hierarchy_datasets {
        dataset_template {
          location = var.region
        }
      }
    }
  }

  backfill_all {
  }

  depends_on = [
    google_project_service.datastream,
    google_project_service.bigquery
  ]
}

output "instance_connection_name" {
  value       = google_sql_database_instance.postgres.connection_name
  description = "Connection name for client connections"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Name of the created database"
}

# Output the BigQuery dataset ID
output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.payroll_dataset.dataset_id
  description = "The ID of the BigQuery dataset"
}

# Output the Datastream stream ID
output "datastream_stream_id" {
  value       = google_datastream_stream.postgres_to_bigquery.stream_id
  description = "The ID of the Datastream stream"
}
