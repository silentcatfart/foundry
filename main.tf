terraform {
  required_providers {
    azurerm = {
      source                                = "hashicorp/azurerm"
      version                               = "= 3.4.0"
    }

    azuread = {
      source                                = "hashicorp/azuread"
      version                               = "= 2.22.0"
    }

    random = {
      source                                = "hashicorp/random"
      version                               = "= 3.1.3"
    }
  }

  backend "remote" {
    organization                            = "catfarts"

    workspaces {
      name                                  = "foundry"
   }
  }
}

provider "azurerm" {
  features {}
}