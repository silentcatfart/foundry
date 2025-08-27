resource "azurerm_virtual_network" "vnet" {
  depends_on                                        = [azurerm_resource_group.rg]

  name                                              = "${var.azure-resource-name}-vnet"
  location                                          = var.location
  resource_group_name                               = azurerm_resource_group.rg.name
  address_space                                     = [var.vnet-cidr]
  dns_servers                                       = []

  tags = {
      managed-by                                    = "terraform"
      project                                       = var.project-tag
  }
}

resource "azurerm_subnet" "web-snet" {
  depends_on                                        = [azurerm_virtual_network.vnet]

  name                                              = "${var.azure-resource-name}-web-snet"
  resource_group_name                               = azurerm_resource_group.rg.name
  virtual_network_name                              = azurerm_virtual_network.vnet.name
  address_prefixes                                  = [var.snet-0-cidr]
}