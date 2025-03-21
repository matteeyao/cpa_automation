# 🔹 Define the Google Cloud Provider
provider "google" {
  project = "cpa-automation-454219"  # ✅ Set your actual Google Cloud project ID
  region  = "us-central1"            # ✅ Set your region (change if needed)
}

# 🔹 Create a Cloud SQL instance
resource "google_sql_database_instance" "payroll_db" {
  name             = "payroll-db"      # ✅ Unique name for your Cloud SQL instance
  database_version = "POSTGRES_14"     #
  region           = "us-central1"     # ✅ Deploy in this region

  settings {
    tier = "db-f1-micro"  # ✅ Choose the instance size (f1-micro is the smallest & free-tier eligible)
    disk_autoresize = true  # ✅ Automatically increases storage when needed
    availability_type = "ZONAL"  # ✅ "ZONAL" (single zone) or "REGIONAL" (high availability with failover)

    backup_configuration {
      enabled = true  # ✅ Enable automatic backups for disaster recovery
    }
  }
}

# 🔹 Create a Database inside the Cloud SQL instance
resource "google_sql_database" "payroll_service" {
  name     = "payroll_service"  # ✅ Name of the database inside Cloud SQL
  instance = google_sql_database_instance.payroll_db.name  # ✅ Attach to the Cloud SQL instance
}

# 🔹 Create a User for Cloud SQL
resource "google_sql_user" "admin" {
  name     = "payroll_admin"  # ✅ The username for database access
  instance = google_sql_database_instance.payroll_db.name  # ✅ Link user to Cloud SQL instance
  password = "SecureP@ssword123"  # ❗ Replace with a strong password (Never hardcode in production)
}
