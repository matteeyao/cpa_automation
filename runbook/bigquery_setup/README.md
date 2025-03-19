# Set up BigQuery

## Set Up BigQuery dataset

1. Go to BigQuery Console

2. Click **Create Dataset** → Name it `"y_k_suh"`

3. Inside the dataset, click **Create Table**

4. **Enter Table Name**: `y_k_suh`

## Authenticate using a service account

1. **Create a Service Account**:

```zsh
gcloud iam service-accounts create bq-access \
  --description="BigQuery Access for CPA Payroll" \
  --display-name="BigQuery Service Account"
```

2. **Assign BigQuery Roles**:

```zsh
gcloud projects add-iam-policy-binding cpa-automation-454219 \
  --member="serviceAccount:bq-access@cpa-automation-454219.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"
```

3. **Download Service Account Key**:

```zsh
gcloud iam service-accounts keys create key.json \
  --iam-account=bq-access@cpa-automation-454219.iam.gserviceaccount.com
```

4. Set Authentication Using the Service Account:

```zsh
export GOOGLE_APPLICATION_CREDENTIALS="key.json"
```

## Create datasets bigquery

Once your GCP account is set up and the environment variables in settings.py are properly configured, you can upload the datasets to BigQuery by running the following command:

```py
python upload_datasets_in_bq.py
```

This script will automatically load the datasets into BigQuery, ensuring they are ready for use.
