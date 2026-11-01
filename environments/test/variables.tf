variable "subscription_id" {
  description = "Azure サブスクリプション ID"
  type        = string
}

variable "location" {
  description = "リージョン"
  type        = string
  default     = "japaneast"
}

variable "hub_resource_group_name" {
  description = "Hub の Resource Group 名"
  type        = string
  default     = "rg-acp-hub-jpe-001"
}

variable "hub_vnet_name" {
  description = "Hub-VNet 名"
  type        = string
  default     = "vnet-acp-hub-jpe-001"
}
