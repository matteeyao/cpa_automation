variable "project_id" {
  type        = string
  default     = "cpa-automation-454219"
  description = "Google Cloud Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for deployment"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database admin password"
}
