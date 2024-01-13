/*
Deploys management subscription with services shared among other subscriptions, like
  Keyvault
  Jumphost (through Bastion )

*/
locals{
  name_postfix_short      = "${var.solutionShortName}-${var.region}"
  name_postfix            = "${var.solutionName}-${var.region}"
  name_postfix_underscore = "${var.solutionName}_${var.region}"
 }

##
##     Container registry 
##
resource "azurerm_resource_group" "iotRg" {
  name                = lower("${var.management_vnet_config.rg_name}-${local.name_postfix}")
  location            = var.location
  tags                = var.tags 
}
resource "azurerm_container_registry" "acr" {
  name                = lower("${var.acr_name}${var.solutionShortName}${var.region}")  
  resource_group_name = azurerm_resource_group.iotRg.name
  location            = azurerm_resource_group.iotRg.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags 
}

## ACR Scope map.  Each repository get a scope map.  Created from list in variables.tf
resource "azurerm_container_registry_scope_map" "acrscopemap" {
 for_each = var.acr_scope_map
    name                    = each.key
    container_registry_name = azurerm_container_registry.acr.name
    resource_group_name     = azurerm_resource_group.iotRg.name
    actions = [
      "repositories/${each.value}/content/read",
      "repositories/${each.value}/content/write"
  ]
}

# Set RBAC for the two SP
# principal_id = az ad sp list --display-name "acr-management-pull-SP" --query [].id --output tsv
resource "azurerm_role_assignment" "roleacrpull" {
 scope                   = azurerm_container_registry.acr.id
 role_definition_name    = "AcrPull" 
 principal_id            = "e54a581b-869a-4ccf-af43-a5add2c6c662" 
} 
#az ad sp list --display-name "acr-management-push-SP" --query [].id --output tsv
resource "azurerm_role_assignment" "roleacrpush" {
 scope                   = azurerm_container_registry.acr.id
 role_definition_name    = "AcrPush" 
 principal_id            = "a59eea58-4d65-4b40-97f1-8d570ec97e53" 
}

resource "azurerm_role_assignment" "roleacrdelete" {
 scope                   = azurerm_container_registry.acr.id
 role_definition_name    = "AcrDelete"
 principal_id            = "48eda8e0-5a11-431e-a191-0bf4b0088a87"
}

# Dev kubelet id
# az aks show -g <resource group> -n <aks cluster name> --query identityProfile.kubeletidentity.objectId -o tsv 
resource "azurerm_role_assignment" "kubeletpull" {
 scope                   = azurerm_container_registry.acr.id
 role_definition_name    = "AcrPull" 
 principal_id            = "eeac8fdc-a6ec-4243-8762-d17922a1b77d" 
}

##
##    Storage account for all subscriptions
##

resource "azurerm_storage_account" "storageAccShared" {
  name                     = var.general_storage_account_name.name
  resource_group_name      = azurerm_resource_group.managementRg.name
  location                 = azurerm_resource_group.managementRg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
  default_to_oauth_authentication = true
}

resource "azurerm_storage_container" "sc-containers" {
  for_each = toset(var.general_storage_account_name.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.storageAccShared.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "storageAccSharedAccess1" {
 scope                   = azurerm_storage_account.storageAccShared.id
 role_definition_name    = "Storage Blob Data Contributor" 
 principal_id            = "67bb2f41-43ad-4081-a5dc-35248f928dda"  # sub-All-experience-SP 
}

resource "azurerm_role_assignment" "storageAccSharedAccess2" {
 scope                   = azurerm_storage_account.storageAccShared.id
 role_definition_name    = "Storage Blob Data Reader" 
 principal_id            = "65250d01-dc78-46f6-a232-9966bffac561"  # Trifork
}



##
##     management network
##

resource "azurerm_resource_group" "managementRg" {
  name                = lower("${var.management_vnet_config.rg_name}-${local.name_postfix}") 
  location            = var.location
  tags                = var.tags 
}

resource "azurerm_virtual_network" "managementVnet" {
  name                = lower("${var.management_vnet_config.name}-${local.name_postfix}")
  address_space       = var.management_vnet_config.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.managementRg.name
  tags                = var.tags
}

resource "azurerm_subnet" "conectivitySubnet" {
  for_each               = var.management_vnet_subnets 
    resource_group_name  = azurerm_resource_group.managementRg.name
    virtual_network_name = azurerm_virtual_network.managementVnet.name
    name                 = each.value["name"]
    address_prefixes     = each.value["address_prefixes"]
 }

##
##     Bastion
##

resource "azurerm_resource_group" "bastionRg" {
  name                   = lower("${var.bastion_config.rg_name}-${local.name_postfix}")
  location               = var.location
  tags                   = var.tags
 }

 resource "azurerm_public_ip" "bastionPip" {
  name                = lower("${var.bastion_config.pip_name}-${local.name_postfix}")
  location            = azurerm_resource_group.bastionRg.location
  resource_group_name = azurerm_resource_group.bastionRg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "bastion" {
  name                   = lower("${var.bastion_config.name}-${local.name_postfix}")
  location               = azurerm_resource_group.bastionRg.location
  resource_group_name    = azurerm_resource_group.bastionRg.name
  tags                   = var.tags

  ip_configuration {
    name                 = lower("${var.bastion_config.pip_name}-${local.name_postfix}")
    subnet_id            = azurerm_subnet.conectivitySubnet["bastion_subnet"].id
    public_ip_address_id = azurerm_public_ip.bastionPip.id
  }
}

##
##     Log Analytics Workspace
##

resource "azurerm_resource_group" "logAnalyticsRg" {
  name                = lower("${var.azure_log_analytics_config.rg_name}-${local.name_postfix}")
  location            = var.location
  tags                = var.tags 
}
resource "azurerm_log_analytics_workspace" "logAnalytics" {
  name                = lower("${var.azure_log_analytics_config.name}-${local.name_postfix}")
  location            = var.location
  resource_group_name = azurerm_resource_group.logAnalyticsRg.name
  sku                 = var.azure_log_analytics_config.sku
  retention_in_days   = var.azure_log_analytics_config.retention_in_days
  tags                = var.tags 
}

##
##     KeyVault
##

resource "azurerm_resource_group" "keyvaultRg" {
  name                = lower("${var.azure_keyvault_config.rg_name}-${local.name_postfix}")
  location            = var.location
  tags                = var.tags 
}

data "azurerm_client_config" "currenttenant" {}

resource "azurerm_key_vault" "keyvault" {
  name                = lower("${var.azure_keyvault_config.name}-${local.name_postfix}")
  location            = var.location
  resource_group_name = azurerm_resource_group.keyvaultRg.name
  tenant_id           = "${data.azurerm_client_config.currenttenant.tenant_id}"
  enable_rbac_authorization       = true
  sku_name            = var.azure_keyvault_config.sku
  tags                = var.tags 
}

resource "azurerm_role_assignment" "keyvaultAccess" {
 scope                   = azurerm_key_vault.keyvault.id
 role_definition_name    = "Key Vault Reader" 
 principal_id            = "ca28db31-b062-4921-92a3-f8a04a229638" 
}

# Save jumphost password in keyvault
resource "azurerm_key_vault_secret" "jumphost_azadmin" {
  name         = "azadmin"
  key_vault_id = azurerm_key_vault.keyvault.id
  value        = random_password.localAdmin.result
}