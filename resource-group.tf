resource "azurerm_resource_group" "rg" {
  name                                              = "${var.resource-prefix}-rg"
  location                                          = var.location

  tags = {
    managed-by                                      = "terraform"
    project                                         = var.project-tag
  }
}