resource "google_bigquery_dataset" "payroll_dataset" {
  dataset_id    = "payroll_analytics"
  friendly_name = "Payroll Analytics Dataset"
  description   = "Dataset for payroll analytics data"
  location      = var.region

  depends_on = [
    google_project_service.bigquery
  ]
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
