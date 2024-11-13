resource "azurerm_public_ip" "pip" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  allocation_method                 = "Static"
  sku                               = "Basic"
  tags                              = "${(local.tags)}"
}