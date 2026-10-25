output "id" {
  description = "Subnet の ID"
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "Subnet 名"
  value       = azurerm_subnet.this.name
}
