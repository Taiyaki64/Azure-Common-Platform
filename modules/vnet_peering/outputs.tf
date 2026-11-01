output "spoke_to_hub_id" {
  description = "Spoke → Hub の Peering ID"
  value       = azurerm_virtual_network_peering.spoke_to_hub.id
}

output "hub_to_spoke_id" {
  description = "Hub → Spoke の Peering ID"
  value       = azurerm_virtual_network_peering.hub_to_spoke.id
}
