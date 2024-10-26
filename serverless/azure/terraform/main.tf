resource "azurerm_storage_account" "te_storage_account" {
  name                     = "stgacc${random_id.rand_id.hex}"
  resource_group_name      = azurerm_resource_group.te_resource_group.name
  location                 = azurerm_resource_group.te_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "topics-extractor"
  }
}

resource "azurerm_storage_container" "te_blob_container" {
  name                  = "transcripts"
  storage_account_name  = azurerm_storage_account.te_storage_account.name
  container_access_type = "private"
}

resource "azurerm_service_plan" "te_service_plan" {
  name                = "topics-extractor-service-plan"
  resource_group_name = azurerm_resource_group.te_resource_group.name
  location            = azurerm_resource_group.te_resource_group.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags = {
    environment = "topics-extractor"
  }
}

resource "azurerm_application_insights" "te_app_insights" {
  name                = "appinsights${random_id.rand_id.hex}"
  resource_group_name = azurerm_resource_group.te_resource_group.name
  location            = azurerm_resource_group.te_resource_group.location
  application_type    = "web"
  tags = {
    environment = "topics-extractor"
  }
}

resource "azurerm_linux_function_app" "te_function_app" {
  name                       = "funcapp${random_id.rand_id.hex}"
  resource_group_name        = azurerm_resource_group.te_resource_group.name
  location                   = azurerm_resource_group.te_resource_group.location
  storage_account_name       = azurerm_storage_account.te_storage_account.name
  storage_account_access_key = azurerm_storage_account.te_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.te_service_plan.id
  site_config {
    application_stack {
      python_version = "3.11"
    }
    application_insights_connection_string = azurerm_application_insights.te_app_insights.connection_string
    application_insights_key               = azurerm_application_insights.te_app_insights.instrumentation_key
  }
  tags = {
    environment = "topics-extractor"
  }
}