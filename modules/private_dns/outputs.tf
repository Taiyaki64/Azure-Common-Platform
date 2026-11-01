output "id" {
  description = "Private DNS Zone の ID"
  value       = azurerm_private_dns_zone.this.id
}

output "name" {
  description = "Private DNS Zone 名"
  value       = azurerm_private_dns_zone.this.name
}
