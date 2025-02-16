resource "google_service_account" "langfuse_service_account" {
  account_id   = "langfuse-sa"
  display_name = "Langfuse Service Account"
}

resource "google_project_iam_member" "langfuse_service_account_role" {
  for_each = toset([
    "roles/run.admin",
    "roles/storage.objectAdmin",
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.langfuse_service_account.email}"
  role    = each.value
}

resource "google_cloud_run_service_iam_member" "langfuse_web_invoker" {
  service = google_cloud_run_v2_service.langfuse_web.name
  role    = "roles/run.invoker"

  member = "allUsers"
}

resource "google_cloud_run_v2_service" "langfuse_web" {
  name     = "langfuse-web"
  location = var.region
  deletion_protection = false
  ingress  = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.langfuse_service_account.email
    containers {
      name  = "langfuse"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.web_repository_id}/langfuse/langfuse:${var.langfuse_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      ports {
        container_port = 3000
      }
      dynamic "env" {
        for_each = var.env_web
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
          port = 3000
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
  }
}