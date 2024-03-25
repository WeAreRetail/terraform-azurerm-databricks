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
  type = list(string)
  default = []
  description = "List of service endpoint to enable on Databricks vnets"
}
