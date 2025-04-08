locals {
  # Common tags for all resources
  common_tags = {
    project     = var.project_id
    environment = var.environment
    managed_by  = "terraform"
  }

  # Common name prefix for resources
  name_prefix = "payroll-${var.environment}"

  # BigQuery dataset
  bigquery_dataset_id = "payroll_analytics"

  # Cloud SQL instance
  cloud_sql_instance_name = "${local.name_prefix}-postgres"

  # VPC network
  vpc_network_name = "${local.name_prefix}-vpc"

  # Datastream
  datastream_name = "${local.name_prefix}-stream"

  # Tables to sync via Datastream
  datastream_tables = [
    "cpa_firms",
    "businesses",
    "employees",
    "pay_periods",
    "payroll_records",
    "deductions",
    "taxes"
  ]
}
