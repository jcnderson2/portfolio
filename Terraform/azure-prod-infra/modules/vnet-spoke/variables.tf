variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Spoke VNet"
}

variable "address_space" {
  type        = list(string)
  description = "CIDR blocks for the Spoke VNet"
}

variable "subnets" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
  description = "Map of subnet definitions for Spoke VNet"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}