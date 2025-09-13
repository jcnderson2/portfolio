variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "prod-rg-1"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "EastUS"
}

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    managed-by  = "terraform"
    environment = "dev"
    owner       = "jacob"
  }
}

variable "hub_vnet_name" {
  description = "Name of the Hub Virtual Network"
  type        = string
  default     = "vnet-hub"
}

variable "hub_vnet_cidr" {
  description = "Address space for the Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnets" {
  description = "Subnets for the Hub VNet"
  type = map(object({
    name           = string
    address_prefix = string
  }))
  default = {
    gateway    = { name = "GatewaySubnet", address_prefix = "10.0.0.96/27" }
    firewall   = { name = "AzureFirewallSubnet", address_prefix = "10.0.0.0/26" }
    bastion    = { name = "AzureBastionSubnet", address_prefix = "10.0.0.64/27" }
    management = { name = "snet-management", address_prefix = "10.0.2.0/24" }
    shared     = { name = "snet-shared", address_prefix = "10.0.1.0/24" }
    data       = { name = "snet-data", address_prefix = "10.0.3.0/24" }
  }
}

variable "spoke_vnets" {
  description = "Map of spoke VNets with address spaces and subnets"
  type = map(object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      name           = string
      address_prefix = string
    }))
  }))
  default = {
    spoke1 = {
      name          = "vnet-spoke1"
      address_space = ["10.1.0.0/16"]
      subnets = {
        app = { name = "snet-app", address_prefix = "10.1.0.0/24" }
        db  = { name = "snet-db", address_prefix = "10.1.1.0/24" }
      }
    }
    spoke2 = {
      name          = "vnet-spoke2"
      address_space = ["10.2.0.0/16"]
      subnets = {
        web = { name = "snet-web", address_prefix = "10.2.0.0/24" }
      }
    }
    spoke3 = {
      name          = "vnet-spoke3"
      address_space = ["10.3.0.0/16"]
      subnets = {
        batch = { name = "snet-batch", address_prefix = "10.3.0.0/24" }
      }
    }
  }
}


variable "trusted_admin_ips" {
  description = "Your trusted public IP(s) for admin access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # REPLACE
}

locals {
  hub_subnets    = module.hub_vnet.hub_subnet_ids
  spoke1_subnets = module.spoke_vnets["spoke1"].spoke_subnet_ids
  spoke2_subnets = module.spoke_vnets["spoke2"].spoke_subnet_ids
  spoke3_subnets = module.spoke_vnets["spoke3"].spoke_subnet_ids
}

# ---- Hub: Management NSG ----
locals {
  hub_mgmt_rules = [
    {
      name                         = "Deny-Internet-Inbound"
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["0-65535"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.0.0.0/16"]
      description                  = "Block unsolicited internet inbound"
    }
  ]

  hub_shared_rules = [
    {
      name                         = "Allow-VNet-Inbound"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["0-65535"]
      source_address_prefixes      = ["10.0.0.0/16"]
      destination_address_prefixes = ["10.0.0.0/16"]
      description                  = "Intra-VNet + peering"
    },
    {
      name                         = "Deny-Internet-Inbound"
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["0-65535"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.0.0.0/16"]
      description                  = "No direct internet inbound"
    }
  ]

  spoke1_app_rules = [
    {
      name                         = "Allow-HTTPS-In"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["443"]
      source_address_prefixes      = ["10.0.0.0/16"]
      destination_address_prefixes = ["10.1.0.0/24"]
      description                  = "HTTPS from within estate (web tier)"
    },
    {
      name                         = "Allow-HTTP-In"
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["80"]
      source_address_prefixes      = ["10.0.0.0/16"]
      destination_address_prefixes = ["10.1.0.0/24"]
      description                  = "HTTP from within estate (web tier)"
    }
  ]

  spoke1_db_rules = [
    {
      name                         = "Allow-SQL-from-App"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["3601"] # adjust for your DB
      source_address_prefixes      = ["10.1.0.0/24"]
      destination_address_prefixes = ["10.1.1.0/24"]
      description                  = "Allow DB from App subnet"
    },
    {
      name                         = "Deny-All-Else"
      priority                     = 4096
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["0-65535"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.1.1.0/24"]
      description                  = "Default deny"
    }
  ]

  spoke2_web_rules = [
    {
      name                         = "Allow-HTTP-From-Internet"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["80"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.2.0.0/24"]
    },
    {
      name                         = "Allow-HTTPS-From-Internet"
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["443"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.2.0.0/24"]
    }
  ]

  spoke3_batch_rules = [
    {
      name                         = "Deny-Internet-Inbound"
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["0-65535"]
      destination_port_ranges      = ["0-65535"]
      source_address_prefixes      = ["0.0.0.0/0"]
      destination_address_prefixes = ["10.3.0.0/24"]
    }
  ]
}