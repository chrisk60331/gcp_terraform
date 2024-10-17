# Google Cloud Run Service
resource "google_cloud_run_service" "main" {
  name     = "${var.app_name}-service-${var.env_name}"
  location = var.region  # e.g., "us-central1"

  labels = {
    customer_name = var.org_name
    project_name  = var.app_name
  }

  template {
    metadata {
      annotations = {
        # Set the minimum number of instances (optional)
        "autoscaling.knative.dev/minScale" = tostring(var.desired_count)
        # Set the CPU to be always allocated (optional)
        "run.googleapis.com/cpu-throttling" = "false"
      }
    }

    spec {
      containers {
        image = var.container_image

        resources {
          limits = {
            cpu    = var.cpu_limit    # e.g., "1"
            memory = var.memory_limit # e.g., "512Mi"
          }
        }

        ports {
          name           = "http1"  # Name of the port (arbitrary)
          container_port = var.container_port
        }

        # Optional: Environment variables
        # env = [
        #   {
        #     name  = "ENV_VAR_NAME"
        #     value = "value"
        #   },
        # ]
      }

      # Optional: Service account for the container to use
      # service_account_name = var.service_account_email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM Policy to Allow Unauthenticated Access (Optional)
resource "google_cloud_run_service_iam_member" "noauth" {
  location = google_cloud_run_service.main.location
  service  = google_cloud_run_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
