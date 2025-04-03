variable "project_id" {
  type        = string
  default     = "sputter-455519"
  description = "The GCP project ID"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "db_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}
