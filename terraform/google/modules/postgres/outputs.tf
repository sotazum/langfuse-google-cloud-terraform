output "cloudsql_internal_ip" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}

output "postgres_user" {
  value = google_sql_user.langfuse_user.name
}

output "postgres_password" {
  value = google_sql_user.langfuse_user.password
}

output "postgres_db" {
  value = google_sql_database_instance.postgres_instance.name
}