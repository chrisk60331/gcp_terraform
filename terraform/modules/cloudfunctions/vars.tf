variable "app_name" {
  description = "Application name"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., 'dev', 'prod')"
  type        = string
}

variable "region" {
  description = "GCP region for the function"
  type        = string
  default     = "us-central1"
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "trigger_bucket_name" {
  description = "Name of the GCS bucket that triggers the function"
  type        = string
}

# Optional: If you have a specific service account for the function
variable "function_service_account_email" {
  description = "Service account email for the Cloud Function (optional)"
  type        = string
  default     = null
}
