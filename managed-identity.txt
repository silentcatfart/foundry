resource "azurerm_user_assigned_identity" "managed-id" {
  depends_on                                     = [azurerm_resource_group.rg]

  resource_group_name                            = azurerm_resource_group.rg.name
  location                                       = var.location
  name                                           = "${var.azure-resource-name}-id"
  tags                                           = "${(local.tags)}"
}