## Creates storage account with containers. 

/*Usage example : 
module "storage" {
  source                = "./Modules/Storageaccount"
  location              = var.location
  rg_name               = azurerm_resource_group.rg.name
  tags                  = var.tags
  name                  = "satest32995xx" 
  containers            = [ "con1", "con2"]
  public_access         = true
  privateEndpointSubnet = module.network.subnetID[0]
  CORS_allowed_origins  = ["localhost:3000", "test.dev.lhexperience.dk" ]
}
*/
/*
module "Global_Constants" {
   source = "../Global_Constants"
}
*/

module "Global" {
  #source = "git::git@github.com:LEGO-House/terraform-modules.git//Terraform/Modules/Global?ref=master"
  #source = "git@github.com:LEGO-House/terraform-modules.git//Terraform/Modules/Global?ref=master"

  ## Works.  Fine grained Token created in Git
  #source = "git::https://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@github.com/TomBramsen/work.git//Modules/Global_Constants?ref=main"

  source = "git::ssh://git@github.com/TomBramsen/TerraformModules.git//Modules/Global"
  # source = "git::https://4252d070eaea3e9364b1b51539e24c198829613e:TerrraformModules@github.com/LEGO-House/terraform-modules.git//Terraform/Modules/Global"

}


resource "azurerm_resource_group" "rg-storageaccount" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

 # this value has to be greater than restorePolicy.days
locals { 
  delete_retention_days = var.retention_days + 7
  delete_retention_days_minus_1 =  var.retention_days + 6
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
  public_network_access_enabled   = true  # we use either from known net or all.  False would prohobit Github access

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
  depends_on = [ azurerm_resource_group.rg-storageaccount ]
}


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
   principal_id            =  module.Global.AADGroup_Read_access_all # ""65250d01-dc78-46f6-a232-9966bffac561"  # Trifork
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
  value = azurerm_private_endpoint.StorageAccountEndpoint.id
}
