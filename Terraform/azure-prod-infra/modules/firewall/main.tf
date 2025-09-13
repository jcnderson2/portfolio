resource "azurerm_public_ip" "fw" {
  name                = "pip-fw-hub"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "fw" {
  name                = "fw-policy-hub"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "fw-hub"
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw.id

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

# resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
#  name                       = "fw-diag"
#  target_resource_id         = azurerm_firewall.hub.id
# 
#  enabled_log {
#    category = "AzureFirewallApplicationRule"
#  }
#  enabled_log {
#    category = "AzureFirewallNetworkRule"
#  }
#  enabled_log {
#    category = "AzureFirewallDnsProxy"
#  }
#}