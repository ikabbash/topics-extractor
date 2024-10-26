output "storage_account_name" {
  value = azurerm_storage_account.te_storage_account.name
}

output "resource_group_name" {
  value = azurerm_resource_group.te_resource_group.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.te_function_app.name
}