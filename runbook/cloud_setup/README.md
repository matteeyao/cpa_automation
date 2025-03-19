# Set up Google Cloud Infrastructure

## Create a Google Cloud Project

1. **Go to** [Google Cloud Console](https://console.cloud.google.com/welcome/)

2. Click **Create Project** → Name it `"CPA Automation"`

3. Copy your **Project ID** (needed for BigQuery and Cloud Functions)

## Enable Required APIs

1. In **Google Cloud Console**, go to **APIs & Services** → **Enable APIs**

2. Enable these APIs:

  * **BigQuery API** (for payroll data storage)

  * **Google Sheets API** (for syncing data)

  * **Google Drive API** (for managing Google Sheets)

  * **Cloud Functions API** (for automated processing)

  * **Cloud Pub/Sub API** (for event-driven processing)
