resource "google_bigquery_dataset" "payroll_dataset" {
  dataset_id    = "payroll_analytics"
  friendly_name = "Payroll Analytics Dataset"
  description   = "Dataset for payroll analytics data"
  location      = var.region

  depends_on = [
    google_project_service.bigquery
  ]
}

resource "google_bigquery_table" "cpa_firms" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "cpa_firms"
  schema     = file("${path.module}/schemas/cpa_firms.json")
}

resource "google_bigquery_table" "businesses" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "businesses"
  schema     = file("${path.module}/schemas/businesses.json")
}

resource "google_bigquery_table" "employees" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "employees"
  schema     = file("${path.module}/schemas/employees.json")
}

resource "google_bigquery_table" "pay_periods" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "pay_periods"
  schema     = file("${path.module}/schemas/pay_periods.json")
}

resource "google_bigquery_table" "payroll_records" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "payroll_records"
  schema     = file("${path.module}/schemas/payroll_records.json")
}

resource "google_bigquery_table" "deductions" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "deductions"
  schema     = file("${path.module}/schemas/deductions.json")
}

resource "google_bigquery_table" "taxes" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "taxes"
  schema     = file("${path.module}/schemas/taxes.json")
}

# BigQuery Views for Analytics
resource "google_bigquery_table" "employee_payroll_summary" {
  dataset_id = google_bigquery_dataset.payroll_dataset.dataset_id
  table_id   = "employee_payroll_summary"

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
}
