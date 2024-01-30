module "Global_Constants" {
   source = "../Global_Constants"
}

resource "azurerm_resource_group" "rg-keyvault" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

data "azurerm_client_config" "currenttenant" {}

resource "azurerm_key_vault" "keyvault" {
   name                       = var.name
   location                   = var.location
   resource_group_name        = var.rg_name
   tenant_id                  = "${data.azurerm_client_config.currenttenant.tenant_id}"
   enable_rbac_authorization  = true
   sku_name                   = var.sku
   tags                       = var.tags 
   purge_protection_enabled   = var.purge_protection

   network_acls {
      bypass         = "AzureServices"
      default_action = "Deny"
      ip_rules       = module.Global_Constants.IP_Whitelist
  }

  depends_on = [ azurerm_resource_group.rg-keyvault ]
}

##
## Give access to Keyvault
##
## - Trifork Entra AD Group gets read access
resource "azurerm_role_assignment" "keyvaultAccessTrifork" {
   scope                      = azurerm_key_vault.keyvault.id
   role_definition_name       = "Key Vault Secrets User" 
   principal_id               = module.Global_Constants.AADGroup_Read_access_all # "65250d01-dc78-46f6-a232-9966bffac561"  # Trifork
}

## The Github SP gets access to update secrets
data "azurerm_client_config" "currentSP" {
}
/*
resource "azurerm_role_assignment" "keyvaultAccessGithubSP" {
  scope                       = azurerm_key_vault.keyvault.id
  role_definition_name        = "Key Vault Secrets Officer" 
  principal_id                = data.azurerm_client_config.currentSP.object_id
}
*/
resource "azurerm_role_assignment" "keyvaultAccessGithubSP2" {
  scope                       = azurerm_key_vault.keyvault.id
  role_definition_name        = "Key Vault Administrator" 
  principal_id                = data.azurerm_client_config.currentSP.object_id
}

## If other users needs update access, loop through list
resource "azurerm_role_assignment" "accessOthers" {
   for_each = toset(var.RBAC_Secrets_Officers_IDs)
   scope                   = azurerm_key_vault.keyvault.id
   role_definition_name    = "Key Vault Secrets Officer" 
   principal_id            = each.value
}

## Add secrets from list.. if any
##
resource "azurerm_key_vault_secret" "secrets" {
   for_each                   = var.secrets
   name                       = each.key
   value                      = each.value
   key_vault_id               = azurerm_key_vault.keyvault.id
   depends_on                 = [ azurerm_key_vault.keyvault ]
}

## Return id of keyvault
output "keyvault_id" {
  value  = azurerm_key_vault.keyvault.id
}

