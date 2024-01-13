terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "b2b43e30-7abd-4d22-80be-cbf9bebd9ac1"
    resource_group_name  = "TerraformShared"
    storage_account_name = "terraformlh001"
    container_name       = "management"
    key                  = "management"
  }
   required_version = ">= 1.1.0"
}
provider "azurerm" {
  features {}
}