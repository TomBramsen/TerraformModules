## Creates storage account with containers. 

/*Usage example : 
module "storage" {
  source                = "./Modules/Storageaccount"
  location              = var.location
  rg_name               = azurerm_resource_group.rg.name
  tags                  = var.tags
  name                  = "satest32995xx" 
  containers            = [ "con1", "con2"]
  privateEndpointSubnet = module.network.subnetID[0]
  CORS_allowed_origins  = ["http://localhost:3000", "http://test.dev.lhexperience.dk" ]
}
*/


module "Global_Constants" {
   source = "../Global_Constants"
}

resource "azurerm_resource_group" "rg-storageaccount" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

resource "azurerm_storage_account" "storageaccount" {
  name                            = var.name
  resource_group_name             = var.rg_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  default_to_oauth_authentication = var.useRBACauth
  allow_nested_items_to_be_public = false
  tags                            = var.tags
  public_network_access_enabled   = true
  blob_properties {
    
    dynamic "cors_rule" {
      for_each = length(var.CORS_allowed_origins) == 0 ? [] : [1]
      content {
        allowed_headers = ["*"]
        allowed_methods = var.CORS_allowed_methods
        allowed_origins = var.CORS_allowed_origins
        exposed_headers = ["*"]
        max_age_in_seconds = 3600
      }
    } 
    
    change_feed_enabled     = "true"
    versioning_enabled      = "true"

    restore_policy {
      days = 30 
    }
    delete_retention_policy {
      days                  = 40   # this value has to be greater than ARM value restorePolicy.days
    }
    container_delete_retention_policy {
        days                = "30"
    }
  }
  depends_on = [ azurerm_resource_group.rg-storageaccount ]
}


resource "azurerm_storage_account_network_rules" "stnetrules1" {
  count                 = var.privateEndpointSubnet == "" ? 0  : 1
  storage_account_id    = azurerm_storage_account.storageaccount.id
  default_action        = "Deny"
  bypass                = [ "AzureServices"]
  ip_rules              = module.Global_Constants.IP_Whitelist
  depends_on = [ azurerm_storage_account.storageaccount ]
}

## Create private endpoint to storage account

##
## Private Endpoint for storage account
##
resource "azurerm_private_endpoint" "StorageAccountEndpoint" {
  count               = var.privateEndpointSubnet == "" ? 0  : 1
  name                = "endpoint-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.privateEndpointSubnet

  private_service_connection {
    name                           = "sc-${var.name}"
    private_connection_resource_id = azurerm_storage_account.storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

## Create containers from list

resource "azurerm_storage_container" "containers" {
  for_each = toset(var.containers)
  name                  = lower(each.value)
  storage_account_name  = azurerm_storage_account.storageaccount.name
  container_access_type = "private"
}

## Create RBAC roles.   
##  - Only relevant if RBAC was chosen

resource "azurerm_role_assignment" "accessTrifork" {
   count                   = var.useRBACauth ? 1  : 0
   scope                   = azurerm_storage_account.storageaccount.id
   role_definition_name    = "Storage Blob Data Reader" 
   principal_id            =  module.Global_Constants.AADGroup_Read_access_all # ""65250d01-dc78-46f6-a232-9966bffac561"  # Trifork
}

## Assign role to current user
data "azurerm_client_config" "currentSP" {
}
resource "azurerm_role_assignment" "keyvaultAccessGithubSP" {
  count                   = var.useRBACauth ? 1  : 0
  scope                    = azurerm_storage_account.storageaccount.id
  role_definition_name     = "Storage Blob Data Contributor" 
  principal_id             = data.azurerm_client_config.currentSP.object_id
}

resource "azurerm_role_assignment" "accessOthers" {
   for_each = toset(var.RBAC_Contributor_IDs)
   scope                   = azurerm_storage_account.storageaccount.id
   role_definition_name    = "Storage Blob Data Contributor" 
   principal_id            = each.value
}

output "storageaccount_id" {
  value  = azurerm_storage_account.storageaccount.id
}

output "container_ids" {
  value =  [ for c in azurerm_storage_container.containers : c.id ]
}
