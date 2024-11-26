resource "google_artifact_registry_repository" "langfuse_repo" {
  provider      = google-beta
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}

resource "google_vpc_access_connector" "connector" {
  name          = "cloud-run-connector"
  region        = var.region
  min_instances = 2
  max_instances = 5
  network       = var.vpc_network_name
  ip_cidr_range = "10.8.0.0/28"
}


resource "google_service_account" "langfuse_service_account" {
  account_id   = "langfuse-service-account"
  display_name = "Langfuse Service Account"
}

resource "google_project_iam_member" "langfuse_service_account_role" {
  for_each = toset([
    "roles/run.admin",
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.langfuse_service_account.email}"
  role    = each.value
}

resource "google_cloud_run_service_iam_binding" "public_service" {
  location = google_cloud_run_v2_service.langfuse_service.location
  service  = google_cloud_run_v2_service.langfuse_service.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_run_v2_service" "langfuse_service" {
  name     = "langfuse"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.langfuse_service_account.email
    containers {
      name  = "langfuse"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/langfuse/langfuse:${var.langfuse_version}"
      resources {
        limits = {
          cpu    = "1"
          memory = "4Gi"
        }
      }
      ports {
        container_port = 3000
      }
      env {
        name  = "DATABASE_URL"
        value = "postgresql://${var.postgres_user}:${var.postgres_password}@${var.cloudsql_internal_ip}/${var.postgres_db}"
      }
      env {
        name  = "NEXTAUTH_SECRET"
        value = var.nextauth_secret
      }
      env {
        name  = "SALT"
        value = var.salt
      }
      env {
        name  = "ENCRYPTION_KEY"
        value = var.encryption_key
      }
      env {
        name  = "NEXTAUTH_URL"
        value = "https://langfuse-${var.project_number}.${var.region}.run.app"
      }
      env {
        name  = "TELEMETRY_ENABLED"
        value = var.telemetry_enabled
      }
      env {
        name  = "LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES"
        value = var.langfuse_enable_experimental_features
      }
      env {
        name  = "LANGFUSE_INIT_ORG_ID"
        value = var.langfuse_init_org_id
      }
      env {
        name  = "LANGFUSE_INIT_ORG_NAME"
        value = var.langfuse_init_org_name
      }
      env {
        name  = "LANGFUSE_INIT_PROJECT_ID"
        value = var.langfuse_init_project_id
      }
      env {
        name  = "LANGFUSE_INIT_PROJECT_NAME"
        value = var.langfuse_init_project_name
      }
      env {
        name  = "LANGFUSE_INIT_PROJECT_PUBLIC_KEY"
        value = var.langfuse_init_project_public_key
      }
      env {
        name  = "LANGFUSE_INIT_PROJECT_SECRET_KEY"
        value = var.langfuse_init_project_secret_key
      }
      env {
        name  = "LANGFUSE_INIT_USER_EMAIL"
        value = var.langfuse_init_user_email
      }
      env {
        name  = "LANGFUSE_INIT_USER_NAME"
        value = var.langfuse_init_user_name
      }
      env {
        name  = "LANGFUSE_INIT_USER_PASSWORD"
        value = var.langfuse_init_user_password
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
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/${google_vpc_access_connector.connector.name}"
      egress    = "ALL_TRAFFIC"
    }
  }
}