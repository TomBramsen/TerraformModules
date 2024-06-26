terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.39.0"
    }
  }

  # Trifork tobr
  backend "azurerm" {
    subscription_id      = "1b3b25cd-2fb6-4f73-a6f7-c2fc0178ce5d"
    resource_group_name  = "TerraformShared"
    storage_account_name = "tbrtrifork01"
    container_name       = "tfstate"
    key                  = "tfstate"
  }
   required_version = ">= 1.1.0"
}
provider "azurerm" {
    features {
       key_vault {
          purge_soft_delete_on_destroy    = true
          recover_soft_deleted_key_vaults = true
       }
       virtual_machine {
          delete_os_disk_on_deletion     = true
          graceful_shutdown              = false
          skip_shutdown_and_force_delete = false
       }
    }
}


