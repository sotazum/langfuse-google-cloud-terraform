# Create a service account for the worker
resource "google_service_account" "langfuse_worker_service_account" {
  account_id   = "langfuse-worker-sa"
  display_name = "Langfuse Worker Service Account"
}

resource "google_project_iam_member" "langfuse_worker_service_account_role" {
  for_each = toset([
    "roles/run.admin",
    "roles/storage.objectAdmin",
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.langfuse_worker_service_account.email}"
  role    = each.value
}

# Deploy Langfuse Worker on Cloud Run
resource "google_cloud_run_v2_service" "langfuse_worker" {
  name     = "langfuse-worker"
  location = var.region
  deletion_protection = false
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.langfuse_worker_service_account.email
    containers {
      name  = "langfuse-worker"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.worker_repository_id}/langfuse/langfuse-worker:${var.langfuse_worker_version}"
      ports {
        container_port = 3030
      }
      dynamic "env" {
        for_each = var.env_worker
        content {
          name  = env.key
          value = env.value
        }
      }
      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 3030
        }
      }
    }
    vpc_access {
      network_interfaces {
        network    = var.network_name
        subnetwork = var.subnet_name
      }
      egress = "ALL_TRAFFIC"
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
  }
}