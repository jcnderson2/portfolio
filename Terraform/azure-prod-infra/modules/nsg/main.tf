resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rules" {
  for_each                       = { for r in var.security_rules : r.name => r }

  name                           = each.value.name
  priority                       = each.value.priority
  direction                      = each.value.direction
  access                         = each.value.access
  protocol                       = each.value.protocol
  source_port_ranges             = each.value.source_port_ranges
  destination_port_ranges        = each.value.destination_port_ranges
  source_address_prefixes        = each.value.source_address_prefixes
  destination_address_prefixes   = each.value.destination_address_prefixes
  description                    = try(each.value.description, null)

  resource_group_name            = var.resource_group_name
  network_security_group_name    = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = var.subnet_ids

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}