output "id" {
  description = "Private Endpoint の ID"
  value       = azurerm_private_endpoint.this.id
}

output "private_ip_address" {
  description = "Private Endpoint のプライベート IP"
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}
