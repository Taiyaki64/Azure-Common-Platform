variable "spoke_name" {
  description = "Spoke の短縮名（Peering 名に使う。例: dev / test）"
  type        = string
}

variable "spoke_resource_group_name" {
  description = "Spoke の Resource Group 名"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Spoke-VNet 名"
  type        = string
}

variable "spoke_vnet_id" {
  description = "Spoke-VNet の ID"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub の Resource Group 名"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub-VNet 名"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub-VNet の ID"
  type        = string
}
