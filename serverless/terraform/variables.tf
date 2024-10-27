variable "region" {
  default     = "us-east1"
  description = "Resources' region"
}

variable "zone" {
  default     = "us-east1-a"
  description = "Resources' zone"
}

# Value is written in the .tfvars file
variable "project_id" {
  default     = ""
  description = "Your GCP project ID"
}

# Value is written in the .tfvars file
variable "google_api_key" {
  default     = ""
  description = "Gemini API key"
}