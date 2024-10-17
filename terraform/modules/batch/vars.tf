variable "job_name" {
  description = "Name of the Batch job"
  type        = string
}

variable "region" {
  description = "GCP region for the job"
  type        = string
  default     = "us-central1"
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "task_group_name" {
  description = "Name of the task group"
  type        = string
  default     = "default-task-group"
}

variable "job_timeout" {
  description = "Job timeout in seconds"
  type        = number
}

variable "job_vcpus" {
  description = "Number of vCPUs required"
  type        = number
}

variable "job_memory" {
  description = "Amount of memory required in MiB"
  type        = number
}

variable "job_image" {
  description = "Container image URI"
  type        = string
}

variable "job_command" {
  description = "Command to run in the container"
  type        = list(string)
}

variable "machine_type" {
  description = "Machine type for the Batch job"
  type        = string
  default     = "e2-standard-4"
}

variable "network" {
  description = "VPC network name or self-link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or self-link"
  type        = string
}
