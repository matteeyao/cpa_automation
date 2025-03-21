# Uploading and Running schema.sql in Cloud SQL (PostgreSQL)

> **NOTE:**
>
> Run the `Deploy Cloud SQL` workflow within GitHub Actions

## Upload `schema.sql` to Google Cloud Storage

* Run the following command to upload your schema file to a Cloud Storage bucket:

```bash
gsutil cp path/to/schema.sql gs://cpa-automation-sql-scripts/
```

* **Make sure**:

  * `schema.sql` exists in the specified location (path/to/schema.sql)

  * The bucket `cpa-automation-sql-scripts` exists. If not, create it:

```bash
gsutil mb -p cpa-automation-454219 -l us-central1 gs://cpa-automation-sql-scripts/
```

## Grant Cloud SQL Service Account Permission

* Your Cloud SQL instance needs read access to the Cloud Storage bucket.

1. **Find the Cloud SQL service account**:

```zsh
gcloud sql instances describe payroll-db-521da1ac --format="value(serviceAccountEmailAddress)"
```

2. **Grant `storage.objectViewer` permission**:

```zsh
gsutil iam ch serviceAccount:[SERVICE_ACCOUNT_EMAIL]:roles/storage.objectViewer gs://cpa-automation-sql-scripts/
```

  * Replace `[SERVICE_ACCOUNT_EMAIL]` with the email you got in **Step 1**

## Import `schema.sql` into Cloud SQL

* Once uploaded, **import the schema** into your `payroll-db` PostgreSQL instance

```zsh
gcloud sql import sql payroll-db-521da1ac \
  gs://cpa-automation-sql-scripts/schema.sql \
  --database=payroll-service \
  --project=cpa-automation-454219
```

* `payroll-db` → Your Cloud SQL instance name

* `gs://cpa-automation-sql-scripts/schema.sql` → Path to the uploaded schema file

* `payroll_service` → The database where the schema should be applied

> **NOTE**:
>
> **Confirm** by selecting `Y` when prompted.
