resource "azurerm_resource_group" "rg-storageaccount" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

resource "azurerm_storage_account" "storageaccount" {
  name                            = var.sa_name
  resource_group_name             = var.rg_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  default_to_oauth_authentication = var.useRBACauth
  allow_nested_items_to_be_public = false
  tags                            = var.tags
  public_network_access_enabled   = true
  blob_properties {
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET","HEAD","POST","PUT"]
      allowed_origins = ["http://localhost:3000", "http://${var.CORS}"]
      exposed_headers = ["*"]
      max_age_in_seconds = 3600
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

## Create private endpoint to storage account

##
## Private Endpoint for storage account
##
resource "azurerm_private_endpoint" "StorageAccountEndpoint" {
  count               = var.createPrivateEndpoint ? 1  : 0
  name                = "endpoint-${var.sa_name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.privateEndpointSubnet

  private_service_connection {
    name                           = "sc-${var.sa_name}"
    private_connection_resource_id = azurerm_storage_account.storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  ip_configuration {
    name                   = "ip-${var.sa_name}"
    private_ip_address     = var.privateEndpointIp
    subresource_name       = "blob" 
  }
}


output "storage_account_ip" {
  value = var.createPrivateEndpoint ? azurerm_private_endpoint.StorageAccountEndpoint[0].private_service_connection[0].private_ip_address : null
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
   principal_id            = "65250d01-dc78-46f6-a232-9966bffac561"  # Trifork
}

## Assign role to current user
data "azurerm_client_config" "currentSP" {
}
resource "azurerm_role_assignment" "keyvaultAccessGithubSP" {
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
