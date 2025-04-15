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

- [x] Compute Security Admin (`roles/compute.securityAdmin`)

## Step 3: Enable replication between Cloud SQL PostgreSQL instance and BigQuery using Datastream

1. **Configure Cloud SQL PostgreSQL for Replication**

* **Create a Publication and Replication Slot**

  * Connect to your PostgreSQL database and run:

```sql
-- Grant replication privileges to a user
ALTER USER [USER_NAME] WITH REPLICATION;

-- Create a publication for all tables (or specific tables)
CREATE PUBLICATION [PUBLICATION_NAME] FOR ALL TABLES;

-- Create a replication slot
SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('[REPLICATION_SLOT_NAME]', 'pgoutput');
```

  * Replace `[USER_NAME]`, `[PUBLICATION_NAME]`, and `[REPLICATION_SLOT_NAME]` with your values

* **Create a Dedicated Datastream User**

```sql
CREATE USER [DATASTREAM_USER] WITH REPLICATION LOGIN PASSWORD '[PASSWORD]';
GRANT SELECT ON ALL TABLES IN SCHEMA [SCHEMA_NAME] TO [DATASTREAM_USER];
```

  * Replace `[DATASTREAM_USER]`, `[PASSWORD]`, and `[SCHEMA_NAME]`

2. **Create Datastream Connection Profiles**

  * **Source (PostgreSQL) Profile**

    * In Datastream, navigate to **Connection Profiles** > **Create Profile**

    * Select **PostgreSQL**

    * Enter database details (host, port, user, password)

    * Choose connectivity method: **IP allowlisting** or **VPC**

    * Run **Test** to validate connectivity

  * **Destination (BigQuery) Profile**

    * Create a new profile for BigQuery.

    * Select your Google Cloud project and region

3. **Create the Datastream Stream**

  * Navigate to **Streams** > **Create Stream**

  * **Stream Details**:

    * Name: `[STREAM_NAME]`

    * Source: PostgreSQL connection profile

    * Destination: BigQuery connection profile

  * **Configure Source**:

    * Provide the replication slot and publication names created earlier

    * Select schemas/tables to replicate (e.g., **All tables from all schemas**)

  * **Configure Destination**:

    * Specify BigQuery dataset location (e.g., `us-central1`)

    * Set **Data Freshness** to `0 seconds` for real-time replication

  * **Start Stream** with **Backfill** to replicate historical data

4. **Validate Replication**

  * Check the stream’s status in the Datastream console (should show **Running**)

  * In BigQuery, verify datasets and tables match your PostgreSQL schemas

  * Test by inserting/updating data in PostgreSQL and confirming changes appear in BigQuery within seconds

## Step 4: Key Considerations

* **Schema Drift**: Datastream automatically updates BigQuery schemas when source tables change

* **Performance**: Backfill may increase load on the source database

* **Security**: Use minimal privileges for the Datastream user and secure connectivity methods

## Step 5: Further Enhancements

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
