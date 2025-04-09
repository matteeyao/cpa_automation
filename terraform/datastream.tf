resource "google_datastream_connection_profile" "postgres_profile" {
  display_name          = "${local.name_prefix}-postgres-profile"
  location              = var.region
  connection_profile_id = "${local.name_prefix}-postgres-profile"

  postgresql_profile {
    hostname = google_sql_database_instance.postgres.private_ip_address
    port     = 5432
    username = google_sql_user.datastream_user.name
    password = var.datastream_password
    database = google_sql_database.database.name
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.private_connection.id
  }

  depends_on = [
    google_project_service.apis["datastream"],
    google_service_networking_connection.private_vpc_connection,
    google_datastream_private_connection.private_connection,
    google_sql_database_instance.postgres,
    google_sql_database.database,
    google_sql_user.user
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# BigQuery Connection Profile
resource "google_datastream_connection_profile" "bigquery_profile" {
  display_name          = "${local.name_prefix}-bigquery-profile"
  location              = var.region
  connection_profile_id = "${local.name_prefix}-bigquery-profile"

  bigquery_profile {}

  depends_on = [
    google_project_service.apis["datastream"]
  ]
}

# Datastream Stream
resource "google_datastream_stream" "postgres_to_bigquery" {
  display_name  = "${local.name_prefix}-stream"
  location      = var.region
  stream_id     = local.datastream_name
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.postgres_profile.id
    postgresql_source_config {
      include_objects {
        postgresql_schemas {
          schema = "public"
          dynamic "postgresql_tables" {
            for_each = local.datastream_tables
            content {
              table = postgresql_tables.value
            }
          }
        }
      }
      max_concurrent_backfill_tasks = 12
      publication                   = "datastream_publication"
      replication_slot              = "datastream_replication_slot"
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery_profile.id
    bigquery_destination_config {
      data_freshness = "900s" # 15 minutes

      single_target_dataset {
        dataset_id = local.bigquery_dataset_id
      }
      source_hierarchy_datasets {
        dataset_template {
          location = var.region
        }
      }
    }
  }

  backfill_all {}

  depends_on = [
    google_datastream_connection_profile.postgres_profile,
    google_datastream_connection_profile.bigquery_profile,
    google_bigquery_dataset.payroll_dataset
  ]
}
