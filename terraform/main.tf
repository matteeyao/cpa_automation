# Payroll Service Infrastructure
# This Terraform configuration sets up the infrastructure for a payroll service application.
#
# Components:
# - Cloud SQL (PostgreSQL) for transactional data
# - BigQuery for analytics and reporting
# - Datastream for CDC (Change Data Capture) from Cloud SQL to BigQuery
# - VPC networking for secure connectivity
#
# File Structure:
# - main.tf: Main configuration file (this file)
# - providers.tf: Provider configuration
# - variables.tf: Input variables
# - locals.tf: Local variables and common values
# - apis.tf: API enablement
# - networking.tf: VPC and networking configuration
# - cloudsql.tf: Cloud SQL configuration
# - bigquery.tf: BigQuery configuration
# - datastream.tf: Datastream configuration
# - outputs.tf: Output values
#
# Usage:
# 1. Initialize Terraform: terraform init
# 2. Plan changes: terraform plan -var="db_password=your_password"
# 3. Apply changes: terraform apply -var="db_password=your_password"
#
# Note: All resources have been organized into their respective files to improve maintainability.

# This file contains the main infrastructure configuration
# Other configurations are split into:
# - providers.tf: Provider configuration
# - apis.tf: API enablement
# - cloudsql.tf: Cloud SQL configuration
# - bigquery.tf: BigQuery configuration
# - datastream.tf: Datastream configuration
# - variables.tf: Input variables
# - outputs.tf: Output values

# Note: All resources have been moved to their respective files to avoid duplication
