resource "google_artifact_registry_repository" "langfuse_web_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.web_repository_id
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "langfuse_worker_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.worker_repository_id
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}

resource "google_artifact_registry_repository" "clickhouse_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.clickhouse_repository_id
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}