output "id" {
  description = "Resource Group の ID"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Resource Group 名"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Resource Group のリージョン"
  value       = azurerm_resource_group.this.location
}
