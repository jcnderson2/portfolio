output "hub_to_spoke_peering_ids" {
  value       = { for k, v in azurerm_virtual_network_peering.hub_to_spoke : k => v.id }
  description = "IDs of hub-to-spoke peering resources"
}

output "spoke_to_hub_peering_ids" {
  value       = { for k, v in azurerm_virtual_network_peering.spoke_to_hub : k => v.id }
  description = "IDs of spoke-to-hub peering resources"
}