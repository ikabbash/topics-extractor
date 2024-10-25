terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "te_resource_group" {
  name     = "topic-extractor-rg"
  location = var.region
  tags = {
    environment = "topic-extractor"
  }
}
