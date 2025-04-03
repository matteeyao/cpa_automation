# Set up Google Cloud Infrastructure

## Step 1: Create a Google Cloud Project

1. **Go to** [Google Cloud Console](https://console.cloud.google.com/welcome/)

2. Click **Create Project** → Name it `"Sputter"`

3. Copy your **Project ID** (needed for BigQuery and Cloud Functions)

## Step 2: Enable Required API Services

1. In **Google Cloud Console**, go to **APIs & Services** → **Enable APIs**

2. Enable these APIs:

  * **BigQuery API** (for payroll data storage)

  * **Google Sheets API** (for syncing data)

  * **Google Drive API** (for managing Google Sheets)

  * **Cloud Functions API** (for automated processing)

  * **Cloud Pub/Sub API** (for event-driven processing)

  * **Cloud SQL Admin API**

  * **Compute Engine API**

  * **Cloud Resource Manager API**

  * **Identity and Access Management (IAM) API**

  * **Service Usage API**

* You can verify that the APIs are enabled with:

```zsh
gcloud services list --enabled | grep -E 'sqladmin|cloudresourcemanager|iam|serviceusage'
```

* This should show all the APIs we just enabled

## Step 3: Authenticate with Google Cloud

* Now that you have the Google Cloud CLI installed, you need to authenticate with your Google Cloud account:

```zsh
# Initialize gcloud and authenticate
gcloud init
```

* This command will:

  1. Open a browser window asking you to log in to your Google account

  2. Ask you to select a Google Cloud project to use

  3. Configure default settings for your gcloud installation

* After authenticating, verify you're logged in and check your project:

```zsh
# Verify authentication
gcloud auth list

# Check your current project
gcloud config get-value project
```

* Make sure the project matches the one you specified in your Terraform variables (`sputter-455519`).

## Step 4: Create a Service Account

* Now, let's create a service account that GitHub Actions will use to deploy resources to your Google Cloud project:

```zsh
# Set your project ID
export PROJECT_ID=sputter-455519

# Create a new service account
gcloud iam service-accounts create github-actions-sa --display-name="GitHub Actions Service Account"

# Grant the necessary roles to the service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Create and download the key file
gcloud iam service-accounts keys create ~/key.json \
    --iam-account=github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com
```

* This creates a service account named `github-actions-sa`, grants it the necessary permissions to manage Cloud SQL instances, and creates a key file (`key.json`) in your home directory.

## Step 5: Create and Download Service Account Key

Next, you need to create and download a key for the service account:

1. In the Google Cloud Console, navigate to IAM & Admin > Service Accounts

2. Find the `terraform-cloudsql` service account you just created

3. Click on the three dots menu (⋮) at the end of the row

4. Select "Manage keys"

5. Click "Add Key" and then "Create new key"

6. Select "JSON" as the key type

7. Click "Create"

A JSON key file will be automatically downloaded to your computer. This file contains the credentials and will be used as the value for the `GCP_CREDENTIALS` secret in GitHub.

Keep this file secure and don't commit it to your repository. This is a sensitive credential that provides access to your Google Cloud resources.

## Step 6: Set Up GitHub Repository Secrets

* Now you need to add the necessary secrets to your GitHub repository for the GitHub Actions workflow to access your Google Cloud project and set the database password:

  1. Open your GitHub repository in a web browser

  2. Go to "Settings" > "Secrets and variables" > "Actions".

  3. Click on "New repository secret" to add the following secrets:

    a. First, add your Google Cloud credentials:

      * Name: `GCP_CREDENTIALS`

      * Value: The contents of the `key.json` file you created earlier

    b. Next, add your database password:

      * Name: `DB_PASSWORD`

      * Value: A secure password for your PostgreSQL database

      * Make sure to use a strong password. You can generate one with:

```zsh
openssl rand -base64 16
```

  4. Verify that both secrets are added by checking that they appear in the list of repository secrets.

* These secrets will be securely stored in GitHub and will be available to your GitHub Actions workflow when it runs. The workflow will use these secrets to authenticate with Google Cloud and set the password for your PostgreSQL database.

## Step 7: Trigger the GitHub Actions Workflow

* Now that you have set up your repository with the necessary files and secrets, you can manually trigger the GitHub Actions workflow to deploy your Cloud SQL PostgreSQL instance:

  1. Go to your GitHub repository in a web browser

  2. Click on the "Actions" tab at the top of the repository

  3. In the left sidebar, you should see the workflow named "Terraform Cloud SQL Deployment"

  4. Click on this workflow

  5. You'll see a button labeled "Run workflow" on the right side. Click on it

  6. A dropdown will appear. Make sure the "Branch: main" is selected (or whichever branch contains your workflow file)

  7. Click the green "Run workflow" button to start the deployment process

  8. The workflow will start running, and you can click on it to see the progress in real-time

  9. The workflow will execute the following steps:

    * Check out your repository code

    * Set up Terraform

    * Initialize Terraform

    * Check the formatting of your Terraform files

    * Validate your Terraform configuration

    * Create a plan showing what resources will be created

    * Apply the changes to create the Cloud SQL instance

  10. Wait for the workflow to complete. This may take several minutes as provisioning a Cloud SQL instance is not instantaneous

  11. Once the workflow completes successfully, you should see green checkmarks next to each step

* The outputs from the Terraform apply step will show the connection name and database name for your newly created Cloud SQL instance

## Step 8: Verify the Cloud SQL Instance

After your GitHub Actions workflow has completed successfully, you should verify that your Cloud SQL PostgreSQL instance was created correctly:

1. Open the Google Cloud Console in your web browser

2. Make sure you're in the correct project (`sputter-455519`)

3. Navigate to the SQL instances page:

  * Click on the navigation menu (hamburger icon) in the top-left corner

  * Scroll down and click on "SQL" under the "Databases" section

4. You should see your newly created PostgreSQL instance named "postgres-instance" in the list.

5. Click on the instance name to view its details, including:

  * Instance ID

  * Connection name

  * PostgreSQL version

  * Region

  * Machine type

6. Verify the database was created by clicking on the "Databases" tab in the left sidebar of the instance details page. You should see "sputter-database" listed

7. You can also verify the user was created by clicking on the "Users" tab. You should see the "postgres" user listed

8. You can also verify the deployment using the gcloud CLI:

```zsh
# List all Cloud SQL instances in your project
gcloud sql instances list

# Get detailed information about your instance
gcloud sql instances describe postgres-instance

# List databases in your instance
gcloud sql databases list --instance=postgres-instance

# List users in your instance
gcloud sql users list --instance=postgres-instance
```
