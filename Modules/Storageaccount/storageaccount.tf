## Creates storage account with containers. 

/*Usage example : 
module "storage" {
  source =  "github.com/TomBramsen/TerraformModules/Modules/Storageaccount"
  location              = var.location
  rg_name               = azurerm_resource_group.rg.name
  tags                  = var.tags
  name                  = "satest32995xx" 
  containers            = [ "con1", "con2"]
  public_access         = true
  CORS_allowed_origins  = ["localhost:3000", "test.dev.lhexperience.dk" ]
}

Specify subnet id to privateEndpointSubnet, if private endpoint is needed

Add "lifecycle_delete_in_containers" container list and lifecycle_delete_after_days
if you need containers to automatically clean up content after a specific number of days
*/

## Global LH Terraform modules.  Import Global Constants
module "Global" {
   source = "github.com/TomBramsen/TerraformModules/Modules/Global"
}

locals { 
  delete_retention_days = var.retention_days + 7
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
  public_network_access_enabled   = true  #  Must be true for Github to reach Storage Account.  We limit access with whitelist ip's

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
    
    change_feed_enabled     = var.retention_days == 0 ?  "false" : "true"  # must be true when using restore policy
    versioning_enabled      = var.retention_days == 0 ?  "false" : "true"

    # 1 - 365 days.   Must be less than delete_retention_policy
    dynamic "restore_policy" {
      for_each = var.retention_days == 0 ? [] : [1]
      content {
        days = "${var.retention_days == 0  ? 1 : var.retention_days}" ## will give error if 0 even when block is not run
       }
    }

    dynamic "delete_retention_policy" {
      for_each = var.retention_days == 0 ? [] : [1]
      content {
        days = local.delete_retention_days     
       }
    }

    # 1 - 365 days
    dynamic "container_delete_retention_policy" {
      for_each = var.retention_days == 0 ? [] : [1]
      content {
        days = local.delete_retention_days         
       }
    }
  }
}

## Apply Whitelist IP Range if relevant
resource "azurerm_storage_account_network_rules" "stnetrules1" {
  count                 = var.public_access ? 0  : 1
  storage_account_id    = azurerm_storage_account.storageaccount.id
  default_action        = "Deny"
  bypass                = [ "AzureServices"]
  ip_rules              = module.Global.IP_Whitelist
  depends_on = [ azurerm_storage_account.storageaccount ]
}

##
# Container lifecycle policy to automatically delete objects
##
resource "azurerm_storage_management_policy" "delete-after-one-day-policy" {
  count = length(var.lifecycle_delete_in_containers) == 0 ? 0: 1
  storage_account_id = azurerm_storage_account.storageaccount.id

  rule {
    name    = "delete-after-number-days"
    enabled = true
    filters {
      prefix_match = var.lifecycle_delete_in_containers 
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than          = var.lifecycle_delete_after_days
      }
    }
  }
}

## Create private endpoint to storage account

##
## Private Endpoint for storage account
##

resource "azurerm_private_endpoint" "StorageAccountEndpoint" {
  count               = length(var.privateEndpointSubnet)
  name                = "endpoint-${count.index}-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.privateEndpointSubnet[count.index]

  private_service_connection {
    name                           = "sc-${count.index}-${var.name}"
    private_connection_resource_id = azurerm_storage_account.storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
 }

# Find the IP Address associated with the private endpoint created above
data "azurerm_private_endpoint_connection" "endpoint_IPs" {
  count               = length(var.privateEndpointSubnet)
  name                = "endpoint-${count.index}-${var.name}"
  resource_group_name =  var.rg_name
  depends_on          = [ azurerm_private_endpoint.StorageAccountEndpoint ]
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
   principal_id            =  module.Global.AADGroup_Read_access_all  
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