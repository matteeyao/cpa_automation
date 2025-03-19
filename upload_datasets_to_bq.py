import bq_functions
import settings

dataset_name = "y_k_suh"
base_path = f"datasets/{dataset_name}"

def upload_to_bigquery(table_id, subfolder):
    bq_functions.csv_to_bigquery(
        project_id=settings.project_id,
        dataset_id=settings.dataset_id,
        table_id=table_id,
        csv_path=f"{base_path}/{subfolder}/{table_id}.csv",
        schema_path=f"{base_path}/{subfolder}/schema.json"
    )

# df = pd.read_csv("{base_path}/table_metadata/table_metadata.csv")

# Upload datasets
upload_to_bigquery("table_metadata", "table_metadata")
upload_to_bigquery("cpa_firm", "cpa_firm")
upload_to_bigquery("business", "business")
upload_to_bigquery("employee", "employee")
upload_to_bigquery("time_entry", "time_entry")
