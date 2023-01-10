resource "azurerm_recovery_services_vault" "rsv" {
  depends_on                        = [azurerm_resource_group.rg]

  name                              = "${var.azure-resource-name}-rsv"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  sku                               = "Standard"
  soft_delete_enabled               = false

  tags                              = "${(local.tags)}"
}

resource "azurerm_backup_policy_vm" "rsv-policy" {
  depends_on                        = [azurerm_recovery_services_vault.rsv]

  name                              = "daily-12am"
  resource_group_name               = azurerm_resource_group.rg.name
  recovery_vault_name               = azurerm_recovery_services_vault.rsv.name
  timezone                          = var.time-zone
  instant_restore_retention_days    = 1

  backup {
    frequency                       = "Daily"
    time                            = "00:00"
  }

  retention_daily {
    count                           = 7
  }
}