resource "azurerm_storage_account" "storage" {
  depends_on                                     = [azurerm_resource_group.rg]

  name                                           = "${var.azure-resource-name-nospace}st"
  location                                       = azurerm_resource_group.rg.location
  resource_group_name                            = azurerm_resource_group.rg.name
  account_tier                                   = "Standard"
  account_kind                                   = "StorageV2"
  account_replication_type                       = "GRS"
  access_tier                                    = "Hot"
  tags                                           = "${(local.tags)}"
}