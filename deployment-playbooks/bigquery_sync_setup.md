# Setting up Cloud SQL to BigQuery Synchronization

## Step 1: Enable Required APIs

1. Go to the Google Cloud Console.

2. Navigate to "APIs & Services" > "Library".

3. Search for and enable the following APIs:

  * Cloud Datastream API

  * Compute Engine API

  * Cloud Resource Manager API

  * Service Networking API

## Step 2: Add roles to GitHub Actions Service Account

- [x] Cloud SQL Admin (`roles/cloudsql.admin`)

  * Required for creating and managing Cloud SQL instances, databases, and users

- [x] BigQuery Admin (`roles/bigquery.admin`)

  * Required for creating and managing BigQuery datasets and tables

- [x] Datastream Admin (`roles/datastream.admin`)

  * Required for creating and managing Datastream connections and streams

- [x] Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)

  * Required for enabling/disabling APIs (datastream.googleapis.com and bigquery.googleapis.com)

- [x] Project IAM Admin (`roles/resourcemanager.projectIamAdmin`)

  * Required for managing IAM policies and service account permissions

- [x] Storage Admin (`roles/storage.admin`)

  * Required for BigQuery operations as it uses Cloud Storage under the hood

- [x] Compute Network Admin (`roles/compute.networkAdmin`)

## Step 3: Further Enhancements

1. **Scheduled Queries**: The configuration doesn't include BigQuery scheduled queries for data transformation. You should add:

  * Scheduled queries running every 15-30 minutes

  * Transformations for analytics-optimized tables

  * Partitioning by pay period

2. **Monitoring**: There's no configuration for:

  * Alerts for replication lag

  * BigQuery job execution monitoring

3. **Data Optimization**: Consider adding:

  * Partitioning and clustering configurations for BigQuery tables

  * Additional materialized views for common analytics queries
