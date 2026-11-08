output "resource_group_name" {
  description = "Hub の Resource Group 名"
  value       = module.rg.name
}

output "vnet_id" {
  description = "Hub-VNet の ID"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "Hub-VNet 名"
  value       = module.vnet.name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics ワークスペース名"
  value       = module.log_analytics.name
}

