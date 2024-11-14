resource "azurerm_public_ip" "pip-01" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-livekit-01-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  allocation_method                 = "Static"
  sku                               = "Basic"
  tags                              = "${(local.tags)}"
}

resource "azurerm_public_ip" "pip-02" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-vtt-prd-01-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  allocation_method                 = "Static"
  sku                               = "Basic"
  tags                              = "${(local.tags)}"
}

resource "azurerm_public_ip" "pip-03" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-vtt-tst-01-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  allocation_method                 = "Static"
  sku                               = "Basic"
  tags                              = "${(local.tags)}"
}