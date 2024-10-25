variable "region" {
  default     = "East Us"
  description = "Resources' region"
}

# random string to name VM, Storage account, and the multi-cognitive resources with
resource "random_id" "rand_id" {
  byte_length = 4
}

# Create .tfvars and define the subscription ID in it
variable "subscription_id" {
  default     = ""
  description = "Your Azure subscription ID"
}