resource "azurerm_virtual_network" "vnet" {
  depends_on                                        = [azurerm_resource_group.rg]

  name                                              = "${var.resource-prefix}-vnet"
  location                                          = var.location
  resource_group_name                               = azurerm_resource_group.rg.name
  address_space                                     = [var.vnet-address]
#  dns_servers                                       = var.dns-servers
  dns_servers                                       = var.dns-servers-aad

  tags = {
      managed-by                                    = "terraform"
      project                                       = var.project-tag
  }
}

resource "azurerm_subnet" "web-snet" {
  depends_on                                        = [
                                                    azurerm_virtual_network.vnet,
                                                    azurerm_resource_group.rg
                                                    ]

  name                                              = "${var.resource-prefix}-web-snet"
  resource_group_name                               = azurerm_resource_group.rg.name
  virtual_network_name                              = azurerm_virtual_network.vnet.name
  address_prefixes                                  = [var.snet-web-address]
}

resource "azurerm_subnet" "bastion-snet" {
  depends_on                                        = [
                                                    azurerm_virtual_network.vnet,
                                                    azurerm_resource_group.rg
                                                    ]

  name                                              = "AzureBastionSubnet"
  resource_group_name                               = azurerm_resource_group.rg.name
  virtual_network_name                              = azurerm_virtual_network.vnet.name
  address_prefixes                                  = [var.snet-bastion-address]
}

resource "azurerm_subnet" "ad-snet" {
  depends_on                                        = [
                                                    azurerm_virtual_network.vnet,
                                                    azurerm_resource_group.rg
                                                    ]

  name                                              = "ActiveDirectory"
  resource_group_name                               = azurerm_resource_group.rg.name
  virtual_network_name                              = azurerm_virtual_network.vnet.name
  address_prefixes                                  = [var.snet-ad-address]
}
