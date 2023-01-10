resource "azurerm_resource_group" "rg" {
  name                                              = "${var.azure-resource-name}-rg"
  location                                          = var.location

  tags = {
    managed-by                                      = "terraform"
    project                                         = var.project-tag
  }
}