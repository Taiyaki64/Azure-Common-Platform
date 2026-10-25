output "id" {
  description = "VM の ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "private_ip" {
  description = "VM のプライベート IP"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip" {
  description = "VM のパブリック IP（enable_public_ip = false の場合は null）"
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}
