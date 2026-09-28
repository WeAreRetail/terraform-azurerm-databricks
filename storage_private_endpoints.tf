locals {
  storage_id = "${azurerm_databricks_workspace.self.managed_resource_group_id}/providers/Microsoft.Storage/storageAccounts/${azurecaf_name.storage.result}"

  storage_private_endpoints = var.storage_private_endpoint == null ? {} : {
    blob = var.storage_private_endpoint.blob_dns_zone_ids
    dfs  = var.storage_private_endpoint.dfs_dns_zone_ids
  }
}

# The DBFS storage account is created by Azure Databricks in the managed resource group.
# The Databricks deny assignment on this group allows private endpoint connections and their approval.
module "storage_private_endpoint" {
  source  = "WeAreRetail/private-endpoint/azurerm"
  version = "1.0.1"

  for_each = local.storage_private_endpoints

  resource_group_name = var.resource_group_name
  subnet_id           = var.storage_private_endpoint.subnet_id
  resource_id         = local.storage_id
  caf_prefixes        = var.caf_prefixes

  private_dns_zone_group = [{
    name = basename(each.value[0])
    ids  = each.value
  }]

  subresource_names = [each.key]
}
