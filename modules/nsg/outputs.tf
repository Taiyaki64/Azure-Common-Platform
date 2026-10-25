output "id" {
  description = "NSG の ID"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "NSG 名"
  value       = azurerm_network_security_group.this.name
}
