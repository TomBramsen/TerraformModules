resource "azurerm_storage_account" "res-0" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = "westeurope"
  name                            = "satest32995xx"
  resource_group_name             = "ModuleTest"
  tags = {
    environment = "leg"
  }
}
