output "default_compute_service_account" {
  value = data.google_compute_default_service_account.sa_default_compute.email
}

output "default_app_engine_service_account" {
  value = data.google_app_engine_default_service_account.sa_default_app_engine.email
}

output "cloud_function_bucket_name" {
  value = google_storage_bucket.cloud_function_bucket.name
}