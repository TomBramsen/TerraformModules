terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.39.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "0d7ee0d7-f9e4-4089-bcc1-f0cfeacb104c"
    resource_group_name  = "terraform"
    storage_account_name = "terrafrom999000"
    container_name       = "state"
    key                  = "state"
  }
   required_version = ">= 1.1.0"
}
provider "azurerm" {
    features {}
}


