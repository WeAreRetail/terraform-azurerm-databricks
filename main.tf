locals {
  specific_tags = {
    "description" = var.description
  }

  parent_tags         = { for n, v in data.azurerm_resource_group.parent_group.tags : n => v if n != "description" }
  tags                = { for n, v in merge(local.parent_tags, local.specific_tags) : n => v if v != "" }
  public_subnet_name  = "databricks-public"
  private_subnet_name = "databricks-private"

  managed_group_name = "databricks-rg-${azurecaf_name.self.result}-${random_string.databricks.result}"
}

data "azurerm_resource_group" "parent_group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "managed_vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_network_security_group" "databricks" {
  name                = var.nsg_name
  resource_group_name = var.resource_group_name
}

resource "azurecaf_name" "self" {
  name          = ""
  resource_type = "azurerm_databricks_workspace"
  prefixes      = var.caf_prefixes
  suffixes      = []
  use_slug      = true
  clean_input   = true
  separator     = ""
}

resource "azurecaf_name" "storage" {
  name          = format("%02d", 99)
  resource_type = "azurerm_storage_account"
  prefixes      = var.caf_prefixes
  suffixes      = []
  use_slug      = true
  clean_input   = true
  random_length = 5
  separator     = "-"
}

resource "random_string" "databricks" {
  special = false
  length  = 13

  lifecycle {
    ignore_changes = all
  }
}


resource "azurerm_databricks_workspace" "self" {
  name                          = azurecaf_name.self.result
  location                      = data.azurerm_resource_group.parent_group.location
  resource_group_name           = data.azurerm_resource_group.parent_group.name
  tags                          = local.tags
  sku                           = "premium"
  managed_resource_group_name   = local.managed_group_name
  public_network_access_enabled = true

  custom_parameters {
    no_public_ip         = true
    public_subnet_name   = local.public_subnet_name
    private_subnet_name  = local.private_subnet_name
    virtual_network_id   = data.azurerm_virtual_network.managed_vnet.id
    storage_account_name = azurecaf_name.storage.result

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }
}

resource "azurerm_subnet" "public" {
  name                              = local.public_subnet_name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = data.azurerm_virtual_network.managed_vnet.name
  address_prefixes                  = var.public_subnet_address_prefixes
  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "databricks-public-delegation"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
  service_endpoints = var.service_endpoint_list
}

resource "azurerm_subnet" "private" {
  name                              = local.private_subnet_name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = data.azurerm_virtual_network.managed_vnet.name
  address_prefixes                  = var.private_subnet_address_prefixes
  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "databricks-private-delegation"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
  service_endpoints = var.service_endpoint_list
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = data.azurerm_network_security_group.databricks.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = data.azurerm_network_security_group.databricks.id
}

module "logs_storage" {
  source  = "WeAreRetail/storage-account/azurerm"
  version = "2.1.0"

  count = var.enable_log_storage ? 1 : 0

  caf_prefixes              = var.caf_prefixes
  resource_group_name       = var.resource_group_name
  instance_index            = 2
  description               = "Databricks Logs"
  custom_tags               = { purpose = "databricks-logs" }
  shared_access_key_enabled = false
  is_hns_enabled            = true
  containers_list = [
    { name = "logs", access_type = "private" }
  ]
  skuname = "Standard_LRS"
}
