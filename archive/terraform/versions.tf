# ARCHIVED - not deployed. See README.md. Bicep in ../../bicep is the source of truth.
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }

  # The original Terraform Cloud workspace (org "catfarts", workspace "foundry") no longer
  # holds any state. Add a backend here before ever applying this again.
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
