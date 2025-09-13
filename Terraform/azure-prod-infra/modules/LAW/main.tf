resource "azurerm_log_analytics_workspace" "this" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}