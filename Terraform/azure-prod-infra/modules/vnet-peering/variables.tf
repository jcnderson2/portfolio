variable "hub_vnet_id" {
  description = "The ID of the hub VNet"
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the hub VNet"
  type        = string
}

variable "spoke_vnets" {
  description = "Map of spoke VNets with name and id"
  type = map(object({
    name    = string
    vnet_id = string
  }))
}

variable "resource_group" {
  description = "Resource group where the peering will be created"
  type        = string
}