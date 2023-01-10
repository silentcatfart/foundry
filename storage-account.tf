resource "azurerm_storage_account" "hub-storage" {
  depends_on                                     = [azurerm_resource_group.net-rg]

  name                                           = "${var.azure-resource-name-nospace}st"
  location                                       = azurerm_resource_group.net-rg.location
  resource_group_name                            = azurerm_resource_group.net-rg.name
  account_tier                                   = "Standard"
  account_kind                                   = "StorageV2"
  account_replication_type                       = "GRS"
  access_tier                                    = "Hot"
  tags                                           = "${(local.tags)}"
}

resource "azurerm_private_endpoint" "hub-st-blob-pe" {
  depends_on                                     = [azurerm_storage_account.hub-storage]

  name                                           = "${var.azure-resource-name}-hub-st-blob-pe"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.net-rg.name
  subnet_id                                      = azurerm_subnet.snet-hub-privatelink.id
  tags                                           = "${(local.tags)}"

  private_dns_zone_group {
    name                                         = "privatelink.blob.core.windows.net"
    private_dns_zone_ids                         = ["/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-pdnsz-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
  }

  private_service_connection {
    name                                         = "${var.azure-resource-name}-hub-st-blob-psc"
    private_connection_resource_id               = azurerm_storage_account.hub-storage.id
    subresource_names                            = ["blob"]
    is_manual_connection                         = false
  }
}

resource "azurerm_private_endpoint" "hub-st-table-pe" {
  depends_on                                     = [azurerm_storage_account.hub-storage]

  name                                           = "${var.azure-resource-name}-hub-st-table-pe"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.net-rg.name
  subnet_id                                      = azurerm_subnet.snet-hub-privatelink.id
  tags                                           = "${(local.tags)}"

  private_dns_zone_group {
    name                                         = "privatelink.table.core.windows.net"
    private_dns_zone_ids                         = ["/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-pdnsz-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"]
  }

  private_service_connection {
    name                                         = "${var.azure-resource-name}-hub-st-table-psc"
    private_connection_resource_id               = azurerm_storage_account.hub-storage.id
    subresource_names                            = ["table"]
    is_manual_connection                         = false
  }
}

resource "azurerm_private_endpoint" "hub-st-queue-pe" {
  depends_on                                     = [azurerm_storage_account.hub-storage]

  name                                           = "${var.azure-resource-name}-hub-st-queue-pe"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.net-rg.name
  subnet_id                                      = azurerm_subnet.snet-hub-privatelink.id
  tags                                           = "${(local.tags)}"

  private_dns_zone_group {
    name                                         = "privatelink.queue.core.windows.net"
    private_dns_zone_ids                         = ["/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-pdnsz-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"]
  }

  private_service_connection {
    name                                         = "${var.azure-resource-name}-hub-st-queue-psc"
    private_connection_resource_id               = azurerm_storage_account.hub-storage.id
    subresource_names                            = ["queue"]
    is_manual_connection                         = false
  }
}

resource "azurerm_private_endpoint" "hub-st-file-pe" {
  depends_on                                     = [azurerm_storage_account.hub-storage]

  name                                           = "${var.azure-resource-name}-hub-st-file-pe"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.net-rg.name
  subnet_id                                      = azurerm_subnet.snet-hub-privatelink.id
  tags                                           = "${(local.tags)}"

  private_dns_zone_group {
    name                                         = "privatelink.file.core.windows.net"
    private_dns_zone_ids                         = ["/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-pdnsz-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"]
  }

  private_service_connection {
    name                                         = "${var.azure-resource-name}-hub-st-file-psc"
    private_connection_resource_id               = azurerm_storage_account.hub-storage.id
    subresource_names                            = ["file"]
    is_manual_connection                         = false
  }
}