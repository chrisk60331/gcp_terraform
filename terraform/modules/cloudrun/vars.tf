variable "app_name" {
  description = "Application name"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., 'dev', 'prod')"
  type        = string
}

variable "region" {
  description = "GCP region for the service"
  type        = string
  default     = "us-central1"
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "desired_count" {
  description = "Desired number of container instances (minScale)"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for the container (e.g., '1')"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for the container (e.g., '512Mi')"
  type        = string
  default     = "512Mi"
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
  default     = 8080
}

variable "service_account_email" {
  description = "Service account email for the Cloud Run service"
  type        = string
  default     = null
}
