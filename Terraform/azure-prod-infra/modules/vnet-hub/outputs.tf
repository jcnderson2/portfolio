output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "ID of the Hub VNet"
}

output "hub_subnet_ids" {
  value       = { for k, s in azurerm_subnet.hub_subnets : k => s.id }
  description = "IDs of Hub subnets"
}