terraform {
  required_version = ">= 1.5.0"
}

module "rg_main" {
  source   = "./modules/resource-group"
  name     = "prod-rg-1"
  location = "eastus"
}

module "hub_vnet" {
  source         = "./modules/vnet-hub"
  location       = var.location
  vnet_name      = var.hub_vnet_name
  address_space  = var.hub_vnet_cidr
  subnets        = var.hub_subnets
  resource_group = module.rg_main.name
}

module "spoke_vnets" {
  source         = "./modules/vnet-spoke"
  for_each       = var.spoke_vnets
  location       = var.location
  vnet_name      = each.value.name
  address_space  = each.value.address_space
  subnets        = each.value.subnets
  resource_group = module.rg_main.name
}

module "vnet_peering" {
  source        = "./modules/vnet-peering"
  hub_vnet_id   = module.hub_vnet.hub_vnet_id
  hub_vnet_name = var.hub_vnet_name
  spoke_vnets = {
    for k, v in module.spoke_vnets :
    k => { name = v.spoke_vnet_name, vnet_id = v.spoke_vnet_id }
  }
  resource_group = module.rg_main.name
}

module "nsg_hub_mgmt" {
  source              = "./modules/nsg"
  name                = "nsg-hub-management"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    management = local.hub_subnets["management"]
  }
  security_rules = local.hub_mgmt_rules
}

module "nsg_hub_shared" {
  source              = "./modules/nsg"
  name                = "nsg-hub-shared"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    shared = local.hub_subnets["shared"]
    data   = local.hub_subnets["data"]
  }
  security_rules = local.hub_shared_rules
}

module "nsg_spoke1_app" {
  source              = "./modules/nsg"
  name                = "nsg-spoke1-app"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    app = local.spoke1_subnets["app"]
  }
  security_rules = local.spoke1_app_rules
}

module "nsg_spoke1_db" {
  source              = "./modules/nsg"
  name                = "nsg-spoke1-db"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    db = local.spoke1_subnets["db"]
  }
  security_rules = local.spoke1_db_rules
}

module "nsg_spoke2_web" {
  source              = "./modules/nsg"
  name                = "nsg-spoke2-web"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    web = local.spoke2_subnets["web"]
  }
  security_rules = local.spoke2_web_rules
}

module "nsg_spoke3_batch" {
  source              = "./modules/nsg"
  name                = "nsg-spoke3-batch"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
  subnet_ids = {
    batch = local.spoke3_subnets["batch"]
  }
  security_rules = local.spoke3_batch_rules
}

module "firewall" {
  source             = "./modules/firewall"
  rg_name            = module.rg_main.name
  location           = var.location
  firewall_subnet_id = module.hub_vnet.hub_subnet_ids["firewall"]
  law_id             = module.log_analytics.law_id
}

module "bastion" {
  source              = "./modules/bastion"
  name                = "bastion-hub"
  location            = var.location
  resource_group_name = module.rg_main.name
  subnet_id           = local.hub_subnets["bastion"]
  tags                = var.default_tags
}

module "network_watcher" {
  source              = "./modules/network-watcher"
  name                = "prod-nw"
  location            = var.location
  resource_group_name = module.rg_main.name
  tags                = var.default_tags
}

module "log_analytics" {
  source   = "./modules/law"
  rg_name  = module.rg_main.name
  location = var.location
  law_name = "law-prod-infra"
}