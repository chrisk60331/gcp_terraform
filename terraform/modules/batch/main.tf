# Google Cloud Batch Job
resource "google_batch_job" "job" {
  name   = var.job_name
  region = var.region  # Specify the GCP region

  labels = {
    customer_name = var.org_name
    project_name  = var.app_name
  }

  task_groups {
    name = var.task_group_name  # Optional: Name of the task group

    task_count = 1  # Number of tasks to run

    task_spec {
      max_run_duration = "${var.job_timeout}s"  # Timeout for the task

      environment {
        variables = {
          "file_key" = "train_data.csv"
        }
      }

      compute_resource {
        cpu_milli    = var.job_vcpus * 1000  # Convert vCPUs to milliCPU units
        memory_mib   = var.job_memory        # Memory in MiB
      }

      runnables {
        container {
          image_uri = var.job_image  # Container image URI
          entrypoint = var.job_command[0]
          commands   = slice(var.job_command, 1, length(var.job_command))

          options = "--network host"  # Network options if needed

          # Optional: Set up network configurations
          # network = {
          #   network_interfaces = [
          #     {
          #       network    = var.network
          #       subnetwork = var.subnetwork
          #     }
          #   ]
          # }
        }
      }
    }
  }

  allocation_policy {
    instances {
      policy {
        machine_type = var.machine_type  # e.g., "e2-standard-4"

        # Optional: Attach service account
        # service_account {
        #   email = var.service_account_email
        # }
      }

      network_interface {
        network    = var.network
        subnetwork = var.subnetwork
        # Set to true if you don't want an external IP
        no_external_ip_address = false
      }
    }
  }

  logs_policy {
    destination = "CLOUD_LOGGING"  # Send logs to Cloud Logging
  }
}
