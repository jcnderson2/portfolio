# RG outputs
output "resource_group_id" {
  description = "The ID of the created Resource Group"
  value       = module.rg_main.id
}

# Vnet-Hub outputs
output "hub_vnet_id" {
  value = module.hub_vnet.hub_vnet_id
}

output "hub_subnet_ids" {
  value = module.hub_vnet.hub_subnet_ids
}