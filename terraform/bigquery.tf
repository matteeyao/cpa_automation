resource "google_bigquery_dataset" "payroll_dataset" {
  dataset_id    = local.bigquery_dataset_id
  friendly_name = "Payroll Analytics Dataset"
  description   = "Dataset for payroll analytics data"
  location      = var.region

  labels = local.common_tags

  depends_on = [
    google_project_service.apis["bigquery"]
  ]
}

locals {
  bigquery_tables = {
    cpa_firms = {
      schema = "cpa_firms.json"
    },
    businesses = {
      schema = "businesses.json"
    },
    employees = {
      schema = "employees.json"
    },
    pay_periods = {
      schema = "pay_periods.json"
    },
    payroll_records = {
      schema = "payroll_records.json"
    },
    deductions = {
      schema = "deductions.json"
    },
    taxes = {
      schema = "taxes.json"
    }
  }
}

resource "google_bigquery_table" "tables" {
  for_each = local.bigquery_tables

  dataset_id          = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id            = each.key
  schema              = file("${path.module}/schemas/${each.value.schema}")
  deletion_protection = false

  labels = local.common_tags
}

# BigQuery Views for Analytics
resource "google_bigquery_table" "employee_payroll_summary" {
  dataset_id          = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id            = "employee_payroll_summary"
  deletion_protection = false

  depends_on = [
    google_bigquery_table.tables
  ]

  view {
    query          = <<EOF
    SELECT 
      e.first_name,
      e.last_name,
      b.business_name,
      SUM(pr.gross_pay) as total_gross_pay,
      SUM(pr.net_pay) as total_net_pay,
      COUNT(*) as pay_periods
    FROM `${google_bigquery_dataset.payroll_dataset.dataset_id}.employees` e
    JOIN `${google_bigquery_dataset.payroll_dataset.dataset_id}.businesses` b 
      ON e.business_id = b.id
    JOIN `${google_bigquery_dataset.payroll_dataset.dataset_id}.payroll_records` pr 
      ON e.id = pr.employee_id
    GROUP BY e.first_name, e.last_name, b.business_name
    EOF
    use_legacy_sql = false
  }

  labels = local.common_tags
}

# Cloud Resource Connection for BigQuery
resource "google_bigquery_connection" "cloud_resource_connection" {
  connection_id = "cloud-resource-connection"
  location      = var.region
  cloud_resource {}
}

resource "google_project_iam_member" "connection_permission" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_bigquery_connection.cloud_resource_connection.cloud_resource[0].service_account_id}"
}
