resource "google_redis_instance" "langfuse_redis" {
  name              = "langfuse-redis"
  tier              = "STANDARD_HA"
  memory_size_gb    = 1
  region            = var.region
  project           = var.project_id
  reserved_ip_range = "10.0.1.0/29"

  authorized_network = var.network_name

  redis_configs = {
    "maxmemory-policy" = "noeviction"
  }
}