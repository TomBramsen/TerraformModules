

data "azurerm_client_config" "currenttenant" {}

resource "azurerm_key_vault" "keyvault" {
    name                = var.name
    location            = var.location
    resource_group_name = var.resourcegroup
    tenant_id           = data.azurerm_client_config.currenttenant.tenant_id 
    
    # https://learn.microsoft.com/en-us/answers/questions/1101781/what-permission-is-needed-exactly-to-allow-an-app
    access_policy  =[ 
     {
       tenant_id = data.azurerm_client_config.currenttenant.tenant_id
       object_id = data.azurerm_client_config.currenttenant.object_id
       application_id          = ""
       certificate_permissions = [
                  "Get",
                  "List",
                  "Update",
                  "Create",
                  "Import",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                  "ManageContacts",
                  "ManageIssuers",
                  "GetIssuers",
                  "ListIssuers",
                  "SetIssuers",
                  "DeleteIssuers",
                ]
        key_permissions         = [
                  "Get",
                  "List",
                  "Update",
                  "Create",
                  "Import",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                  "GetRotationPolicy",
                  "SetRotationPolicy",
                  "Rotate",
                ]
        secret_permissions      = [
                  "Get",
                  "List",
                  "Set",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                ]
        storage_permissions     = []
          }, 
          {
       tenant_id = data.azurerm_client_config.currenttenant.tenant_id
       object_id = var.kv_acces_object_id
       application_id          = ""
       certificate_permissions = [
                  "Get",
                  "List",
                  "Update",
                  "Create",
                  "Import",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                  "ManageContacts",
                  "ManageIssuers",
                  "GetIssuers",
                  "ListIssuers",
                  "SetIssuers",
                  "DeleteIssuers",
                ]
        key_permissions         = [
                  "Get",
                  "List",
                  "Update",
                  "Create",
                  "Import",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                  "GetRotationPolicy",
                  "SetRotationPolicy",
                  "Rotate",
                ]
        secret_permissions      = [
                  "Get",
                  "List",
                  "Set",
                  "Delete",
                  "Recover",
                  "Backup",
                  "Restore",
                ]
        storage_permissions     = []
           }
     
     ]
         
      enable_rbac_authorization       = false  
      enabled_for_deployment          = false  
      enabled_for_disk_encryption     = false  
      enabled_for_template_deployment = false  
      public_network_access_enabled   = true #  false  
      purge_protection_enabled        = true  
      sku_name                        = var.sku
      soft_delete_retention_days      = 7  
}


