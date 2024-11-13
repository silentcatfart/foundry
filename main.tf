terraform {
  required_providers {
    azurerm = {
      source                                = "hashicorp/azurerm"
      version                               = "= 3.90.0"
    }

    azuread = {
      source                                = "hashicorp/azuread"
      version                               = "= 2.22.0"
    }

    random = {
      source                                = "hashicorp/random"
      version                               = "= 3.1.3"
    }

    template = {
      source                                = "hashicorp/template"
      version                               = "2.2.0"
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