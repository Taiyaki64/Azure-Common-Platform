output "vnet_id" {
  description = "Test-VNet の ID"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "Test-VNet 名"
  value       = module.vnet.name
}

output "resource_group_name" {
  description = "Test の Resource Group 名"
  value       = module.rg.name
}
