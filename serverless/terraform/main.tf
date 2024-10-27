provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name     = "${var.project_id}-cloud-function-bucket"
  location = var.region
}

resource "google_storage_bucket_object" "cloud_function_code" {
  name   = "topics_extractor.zip"
  bucket = google_storage_bucket.cloud_function_bucket.name
  source = "../topics_extractor.zip"
}

# Its better to create another service account but you can use the one that is already created by default in the project
data "google_compute_default_service_account" "sa_default_compute" {
}

resource "google_project_iam_member" "cloud_function_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = data.google_compute_default_service_account.sa_default_compute.member
}

data "google_app_engine_default_service_account" "sa_default_app_engine" {
}

resource "google_project_iam_member" "cloud_function_secret_manager_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = data.google_app_engine_default_service_account.sa_default_app_engine.member
}

# For some reason Cloud Functions can't take regional secrets
resource "google_secret_manager_secret" "gemini_api_secret" {
  secret_id = "GOOGLE_API_KEY"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "regional_secret_version_basic" {
  secret = google_secret_manager_secret.gemini_api_secret.id
  secret_data = var.google_api_key
}

resource "google_cloudfunctions_function" "cloud_function" {
  name                = "topics_extractor"
  runtime             = "python312"
  available_memory_mb = 128 # CHANGE THIS
  source_archive_bucket = google_storage_bucket.cloud_function_bucket.name
  source_archive_object = google_storage_bucket_object.cloud_function_code.name
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.cloud_function_bucket.name
  }

  secret_environment_variables {
      key     = "GOOGLE_API_KEY"
      project_id = var.project_id
      secret  = google_secret_manager_secret.gemini_api_secret.secret_id
      version = "latest"
  }
}