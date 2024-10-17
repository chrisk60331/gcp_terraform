# Create a Google Cloud Storage Bucket
resource "google_storage_bucket" "example_bucket" {
  name          = "${var.app_name}-${var.type}-bucket-${var.env_name}"
  location      = var.region  # e.g., "US"
  force_destroy = true

  labels = {
    customer_name = var.org_name
    project_name  = var.app_name
  }
}

# Archive the Cloud Function code
data "archive_file" "function" {
  type        = "zip"
  source_file = "path/to/your/cloud_function.py"  # Update with your function code path
  output_path = "path/to/cloud_function_payload.zip"
}

# Upload the Cloud Function code to a GCS bucket (optional)
# Alternatively, you can deploy the code directly from the local zip file
# This example uses source code from a local directory

# Create the Cloud Function
resource "google_cloudfunctions_function" "function" {
  name        = "${var.app_name}-${var.env_name}-function"
  description = "Cloud Function triggered by GCS object creation"

  runtime = "python311"  # Use the appropriate runtime
  region  = var.region

  entry_point = "cloud_function_entry_point"  # Replace with your function's entry point

  source_archive_bucket = null  # Not needed if deploying from local source
  source_archive_object = null

  # Deploy the function from local source code
  source_archive_filename = data.archive_file.function.output_path

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.example_bucket.name
  }

  # Service account for the function (optional)
  # service_account_email = var.function_service_account_email

  labels = {
    customer_name = var.org_name
    project_name  = var.app_name
    environment   = var.env_name
  }
}

# IAM Binding to allow Cloud Storage to invoke the Cloud Function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${data.google_project.cloud_storage_project_number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Data source to get the Cloud Storage service account
data "google_project" "cloud_storage" {}

