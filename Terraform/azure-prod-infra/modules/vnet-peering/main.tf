# Hub to Spoke Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spoke_vnets

  name                      = "${var.hub_vnet_name}-to-${each.value.name}"
  resource_group_name       = var.resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = each.value.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# Spoke to Hub Peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spoke_vnets

  name                      = "${each.value.name}-to-${var.hub_vnet_name}"
  resource_group_name       = var.resource_group
  virtual_network_name      = each.value.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
  allow_gateway_transit        = false
}