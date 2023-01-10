
terraform {
  required_providers {
    azurerm = {
      source                                        = "hashicorp/azurerm"
      version                                       = ">= 2.80.0"
    }
  }

  backend "remote" {
    organization                                    = "gatewayticketing"

    workspaces {
      name                                          = "aengleman"
   }
  }
}

provider "azurerm" {
  features {}
}