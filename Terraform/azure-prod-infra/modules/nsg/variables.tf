variable "name" {
  description = "NSG name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Map of subnet IDs to associate with this NSG (keys must be static)"
  type        = map(string)
  default     = {}
}

variable "security_rules" {
  description = <<EOT
List of NSG rules. Example element:
{
  name                       = "Allow-HTTPS-In"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_ranges         = ["*"]
  destination_port_ranges    = ["443"]
  source_address_prefixes    = ["Internet"]
  destination_address_prefixes = ["*"]
  description                = "Allow HTTPS"
}
EOT
  type = list(object({
    name                          = string
    priority                      = number
    direction                     = string
    access                        = string
    protocol                      = string
    source_port_ranges            = list(string)
    destination_port_ranges       = list(string)
    source_address_prefixes       = list(string)
    destination_address_prefixes  = list(string)
    description                   = optional(string)
  }))
  default = []
}