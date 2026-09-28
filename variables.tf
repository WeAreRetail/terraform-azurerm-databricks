variable "nsg_name" {
  type        = string
  description = "Databricks virtual network NSG resource name."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "vnet_name" {
  type        = string
  description = "Injected virtual network name."
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "Databricks private subnet IP ranges."
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "Databricks public subnet IP ranges."
}

variable "description" {
  type        = string
  default     = ""
  description = "Resource description."
}

variable "caf_prefixes" {
  type        = list(string)
  default     = []
  description = "Prefixes to use for caf naming."
}

variable "enable_log_storage" {
  type        = bool
  default     = false
  description = "Enable a dedicated storage for clusters logs."
}

variable "service_endpoint_list" {
  type        = list(string)
  default     = []
  description = "List of service endpoint to enable on Databricks vnets"
}

variable "storage_private_endpoint" {
  type = object({
    subnet_id         = string
    blob_dns_zone_ids = list(string)
    dfs_dns_zone_ids  = list(string)
  })
  default     = null
  description = <<EOT
  (Optional) Private endpoints (blob and dfs) to the Databricks DBFS storage account. If not defined, no private endpoint is created.

  subnet_id - The subnet ID where the private endpoints are created.
  blob_dns_zone_ids - The private DNS zone IDs for the blob endpoint (privatelink.blob.core.windows.net).
  dfs_dns_zone_ids - The private DNS zone IDs for the dfs endpoint (privatelink.dfs.core.windows.net).
  EOT

  validation {
    condition     = var.storage_private_endpoint == null || (length(var.storage_private_endpoint.blob_dns_zone_ids) > 0 && length(var.storage_private_endpoint.dfs_dns_zone_ids) > 0)
    error_message = "blob_dns_zone_ids and dfs_dns_zone_ids must not be empty."
  }
}
