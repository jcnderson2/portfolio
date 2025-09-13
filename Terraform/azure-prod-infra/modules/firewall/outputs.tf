output "fw_private_ip" {
  value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "fw_public_ip" {
  value = azurerm_public_ip.fw.ip_address
}

output "fw_id" {
  value = azurerm_firewall.hub.id
}

output "fw_policy_id" {
  value = azurerm_firewall_policy.fw.id
}