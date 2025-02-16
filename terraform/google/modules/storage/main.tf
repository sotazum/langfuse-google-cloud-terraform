resource "google_storage_bucket" "langfuse_storage" {
  force_destroy               = false
  location                    = upper(var.region)
  name                        = "${var.project_id}_${var.bucket_name}"
  project                     = var.project_id
  public_access_prevention    = "enforced"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}

resource "google_service_account" "service_account" {
  account_id   = "langfuse-gcs-sa"
  display_name = "Langfuse GCS Service Account"
}

resource "google_project_iam_member" "service_account_role" {
  for_each = toset([
    "roles/storage.admin",
    "roles/storage.objectAdmin",
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.service_account.email}"
  role    = each.value
}

resource "google_storage_hmac_key" "key" {
  service_account_email = google_service_account.service_account.email
}