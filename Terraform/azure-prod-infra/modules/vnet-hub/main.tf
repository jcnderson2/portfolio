resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "hub_subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  address_prefixes     = [each.value.address_prefix]
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.hub.name
}