output "id" {
  value       = azurerm_databricks_workspace.self.id
  description = "Workspace ID."
}

output "workspace_name" {
  value       = azurerm_databricks_workspace.self.name
  description = "Workspace URL."
}

output "workspace_url" {
  value       = azurerm_databricks_workspace.self.workspace_url
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
}

output "storage_id" {
  value       = "${azurerm_databricks_workspace.self.managed_resource_group_id}/providers/Microsoft.Storage/storageAccounts/${azurecaf_name.storage.result}"
  description = "Databricks DBFS storage account resource id."
}

output "storage_name" {
  value       = azurecaf_name.storage.result
  description = "Databricks DBFS storage account name."
}

output "managed_group_name" {
  value       = local.managed_group_name
  description = "Databricks managed resource group name."
}

output "logs_storage_id" {
  value       = var.enable_log_storage ? module.logs_storage[0].storage_account_id : null
  description = "The logs storage account id."
}

output "logs_storage_name" {
  value       = var.enable_log_storage ? module.logs_storage[0].storage_account_name : null
  description = "The logs storage account name."
}
