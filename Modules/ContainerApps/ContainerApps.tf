
resource "random_string" "acr_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}



resource "random_string" "resource_prefix" {
  length  = 6
  special = false
  upper   = false
  numeric  = false
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix != "" ? var.resource_prefix : random_string.resource_prefix.result}${var.rg_name}"
  location = var.location
  tags     = var.tags
}


module "container_apps" {
  source                           = "github.com/TomBramsen/TerraformModules/Modules/container_apps/container_apps.tf?ref=feature/aks"
  managed_environment_name         = "${var.resource_prefix != "" ? var.resource_prefix : random_string.resource_prefix.result}${var.managed_environment_name}"
  location                         = var.location
  resource_group_name              = azurerm_resource_group.rg.name
  tags                             = var.tags
  infrastructure_subnet_id         = module.virtual_network.subnet_ids[var.aca_subnet_name] 
  instrumentation_key              = module.application_insights.instrumentation_key
  workspace_id                     = module.log_analytics_workspace.id
  dapr_components                  = [{
                                      name            = var.dapr_name
                                      component_type  = var.dapr_component_type
                                      version         = var.dapr_version
                                      ignore_errors   = var.dapr_ignore_errors
                                      init_timeout    = var.dapr_init_timeout
                                      secret          = [
                                        {
                                          name        = "storageaccountkey"
                                          value       = module.storage_account.primary_access_key
                                        }
                                      ]
                                      metadata: [
                                        {
                                          name        = "accountName"
                                          value       = module.storage_account.name
                                        },
                                        {
                                          name        = "containerName"
                                          value       = var.container_name
                                        },
                                        {
                                          name        = "accountKey"
                                          secret_name = "storageaccountkey"
                                        }
                                      ]
                                      scopes          = var.dapr_scopes
                                     }]
  container_apps                   = var.container_apps
}