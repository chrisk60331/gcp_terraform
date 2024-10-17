# Archive the function code
data "archive_file" "function" {
  type        = "zip"
  source_file = "../../../swye360samodel/lambda_function.py"
  output_path = "../../modules/cloud_functions/lambda_function_payload.zip"
}

# Upload the function code to a GCS bucket
resource "google_storage_bucket" "function_code_bucket" {
  name     = "${var.app_name}-${var.env_name}-function-code"
  location = var.region

  # Optional: Set uniform bucket-level access
  uniform_bucket_level_access = true

  labels = {
    customer_name = var.org_name
    project_name  = var.app_name
    environment   = var.env_name
  }
}

resource "google_storage_bucket_object" "function_code" {
  name   = "lambda_function_payload.zip"
  bucket = google_storage_bucket.function_code_bucket.name
  source = data.archive_file.function.output_path
}

# Create the Cloud Function
resource "google_cloudfunctions_function" "function" {
  name        = "${var.app_name}-${var.env_name}-submit-job"
  description = "Cloud Function equivalent of AWS Lambda function"

  runtime = "python312"  # Use "python311" if "python312" is not available
  region  = var.region

  entry_point = "lambda_handler"  # Entry point function name in your code

  # Source code uploaded to GCS
  source_archive_bucket = google_storage_bucket.function_code_bucket.name
  source_archive_object = google_storage_bucket_object.function_code.name

  # Triggered by Cloud Storage events
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = var.trigger_bucket_name  # The name of the GCS bucket to watch
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

# Note: Logging is enabled by default in Cloud Functions
