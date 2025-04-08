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

variable "vpc_network" {
  description = "The VPC network to use for Cloud SQL private IP. This should be the full resource name of an existing VPC network (e.g., projects/PROJECT_ID/global/networks/NETWORK_NAME)"
  type        = string
  default     = "default"
}
