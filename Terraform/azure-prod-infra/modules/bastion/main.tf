variable "name"                { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id"           { type = string } # AzureBastionSubnet
variable "tags"                { type = map(string) }

resource "azurerm_public_ip" "bastion" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  copy_paste_enabled = true
  file_copy_enabled  = true
  ip_connect_enabled = true
  scale_units        = 2

  tags = var.tags
}

output "id"        { value = azurerm_bastion_host.this.id }
output "public_ip" { value = azurerm_public_ip.bastion.ip_address }