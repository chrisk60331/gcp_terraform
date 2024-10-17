variable "app_name" {
  description = "Application name"
  type        = string
}

variable "type" {
  description = "Type of bucket (e.g., 'data', 'models')"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., 'dev', 'prod')"
  type        = string
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "region" {
  description = "GCP region or location for the bucket"
  type        = string
  default     = "US"
}

# Optional: If you have a specific service account for the function
variable "function_service_account_email" {
  description = "Service account email for the Cloud Function (optional)"
  type        = string
  default     = null
}
