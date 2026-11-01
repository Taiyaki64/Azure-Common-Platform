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
