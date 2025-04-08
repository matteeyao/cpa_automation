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

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}

variable "vpc_network" {
  description = "The name of the VPC network to create for Cloud SQL private IP"
  type        = string
  default     = "sputter-vpc"
}
