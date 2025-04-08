output "instance_connection_name" {
  value       = google_sql_database_instance.postgres.connection_name
  description = "Connection name for client connections"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Name of the created database"
}

output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.payroll_dataset.dataset_id
  description = "The ID of the BigQuery dataset"
}

output "datastream_stream_id" {
  value       = google_datastream_stream.postgres_to_bigquery.stream_id
  description = "The ID of the Datastream stream"
}

output "postgres_private_ip" {
  value       = google_sql_database_instance.postgres.private_ip_address
  description = "Private IP address of the Cloud SQL instance"
}

output "vpc_network_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC network"
}

output "environment" {
  value       = var.environment
  description = "The environment name"
}

output "project_id" {
  value       = var.project_id
  description = "The GCP project ID"
}

output "region" {
  value       = var.region
  description = "The GCP region"
}
