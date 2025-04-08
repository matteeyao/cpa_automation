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

  depends_on = [
    google_project_service.datastream
  ]
}

# BigQuery Connection Profile
resource "google_datastream_connection_profile" "bigquery_profile" {
  display_name          = "bigquery-connection-profile"
  location              = var.region
  connection_profile_id = "bigquery-profile"

  bigquery_profile {}

  depends_on = [
    google_project_service.datastream
  ]
}

# Datastream Stream
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

  backfill_all {}

  depends_on = [
    google_project_service.datastream,
    google_bigquery_dataset.payroll_dataset
  ]
}
