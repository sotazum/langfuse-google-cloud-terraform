resource "google_cloud_run_service_iam_member" "clickhouse_invoker" {
  service = google_cloud_run_v2_service.clickhouse.name
  role    = "roles/run.invoker"

  member = "allUsers"
}

resource "google_cloud_run_v2_service" "clickhouse" {
  name = "clickhouse"

  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.clickhouse_repository_id}/clickhouse/clickhouse-server:${var.clickhouse_version}"
      resources {
        limits = {
          cpu    = "4"
          memory = "16Gi"
        }
      }
      volume_mounts {
        name       = "clickhouse"
        mount_path = "/var"
      }
      ports {
        container_port = 8123
      }
      dynamic "env" {
        for_each = var.env_clickhouse
        content {
          name  = env.key
          value = env.value
        }
      }
    }
    vpc_access {
      network_interfaces {
        network    = var.network_name
        subnetwork = var.subnet_name
      }
    }

    volumes {
      name = "clickhouse"
      nfs {
        server    = google_filestore_instance.clickhouse_filestore.networks[0].ip_addresses[0]
        path      = "/share1"
        read_only = false
      }
    }

    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
  }

  depends_on = [
    google_filestore_instance.clickhouse_filestore
  ]
}

resource "google_filestore_instance" "clickhouse_filestore" {
  name     = "clickhouse-filestore"
  location = "${var.region}-b"
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"
  }

  networks {
    network = var.network_name
    modes   = ["MODE_IPV4"]
  }
}