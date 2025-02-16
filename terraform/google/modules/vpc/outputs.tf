output "network_id" {
  value = google_compute_network.langfuse_vpc.id
}

output "network_name" {
  value = google_compute_network.langfuse_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.langfuse_subnet.name
}