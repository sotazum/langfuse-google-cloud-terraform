output "bucket_name" {
  value = google_storage_bucket.langfuse_storage.name
}

output "hmac_access_key_id" {
  value = google_storage_hmac_key.key.access_id
}

output "hmac_secret_access_key" {
  value = google_storage_hmac_key.key.secret
}