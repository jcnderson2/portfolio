output "spoke_vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "ID of the Spoke VNet"
}

output "spoke_subnet_ids" {
  value       = { for k, s in azurerm_subnet.spoke_subnets : k => s.id }
  description = "IDs of Spoke subnets"
}

output "spoke_vnet_name" {
  value       = azurerm_virtual_network.spoke.name
  description = "Name of the Spoke VNet"
}