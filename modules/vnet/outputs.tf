output "id" {
  description = "Virtual Network の ID"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Virtual Network 名"
  value       = azurerm_virtual_network.this.name
}
