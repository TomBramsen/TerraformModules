module "Global" {
   source = "github.com/TomBramsen/TerraformModules/Modules/Global"
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "ModuleTest"
  tags     = var.tags
 }

 
module "network" {
  source        = "./Modules/network"

  rg_name       = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
  name          = "NetVPNrange"
  address_space = var.vNet.address_space
  subnets       = [
   {
      name              = var.vNet.subnet_name_shared
      ip_range          = var.vNet.subnet_ip_shared
   }, 
   {
      name              = var.vNet.subnet_name_test
      ip_range          = var.vNet.subnet_ip_test
   },
   {
      name              = var.vNet.subnet_name_devicemgmt
      ip_range          = var.vNet.subnet_ip_devicemgmt
   }
  ]
}

/*
module "vm" {
  source        = "./Modules/Vm"

  resourcegroup = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
  name          = "TestVM1"
  netid         = module.network.subnetID[0]
  vm_size       = "Standard_B2s"
}
*/



module "storage" {
  source                = "./Modules/Storageaccount"
  #  source = "github.com/TomBramsen/TerraformModules/Modules/Storageaccount"
  location              = var.location
  rg_name               = azurerm_resource_group.rg.name
  tags                  = var.tags
  name                  = "satest32995xx" 
  containers            = [ "con1", "con2"]
  public_access         = false
  privateEndpointSubnet = [ module.network.subnetID[0] ]
  CORS_allowed_origins  = ["localhost:3000", "test.dev.lhexperience.dk" ]
  retention_days        = 0
  lifecycle_delete_in_containers = [ "con1" ]
  lifecycle_delete_after_days = 33
}

/*

module "kv" {
  source   = "./Modules/keyvault"
  location = var.location
  rg_name  =  azurerm_resource_group.rg.name
  tags     = var.tags
  name     = "kvsatest32995xx"
  secrets  = {  "sqlAdmin" =  module.sql.AdminPSW
                "key3" = "test" }
  public_access = false
  depends_on = [ module.sql ]
}


*/


module "sql" {
  source   = "./Modules/MSSQL"
  location = var.location
  rg_name =  azurerm_resource_group.rg.name
  tags     = var.tags
  name  = "kvsatest329d95xlx"
  databases = [ { name = "testDB",
                  size = 20  } ,
                 { name = "testDB2",
                  size = 30,
                  retention_enabled = false  } ,
              ]       
  privateEndpointSubnet = [ module.network.subnetID[0]]
}


output "endpoints_ips" {
  value            = module.sql.endpoints_ips[*]
}




##
##     Log Analytics Workspace
##

resource "azurerm_resource_group" "logAnalyticsRg" {
  name                = "logs"
  location            = var.location
  tags                = var.tags 
}
resource "azurerm_log_analytics_workspace" "logAnalytics" {
  name                = "loganalytics"
  location            = var.location
  resource_group_name = azurerm_resource_group.logAnalyticsRg.name
  sku                 = var.azure_log_analytics_config.sku
  retention_in_days   = var.azure_log_analytics_config.retention_in_days
  tags                = var.tags 
}

/*
module "sa_diag" {
  source                     = "./Modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logAnalytics.id 
  targets_resource_id        = [module.storage.storageaccount_id] # concat(module.sql.database_ids,[module.storage.storageaccount_id])
  # enable_logs = true
  # specific_metrics =  [ [ "Basic" ], [ "Basic" ]]
  # specific_logs = [ [ "Errors", "Timeouts", "SQLInsights"], [ "Errors", "Timeouts","SQLInsights"]]
}


output "logsCheck" {
  value = module.sa_diag.logs
}

output "metricsCheck" {
   value = module.sa_diag.metrics
}

*/

output "networkID" {
  value = module.network.subnetID
}


locals {
  test =  contains(module.network.subnetID, "test")
  }

# Build id for specific subnet
locals {
  split = split("/",module.network.subnetID[0])
  len   = (length(local.split)) - 1 
  slice = slice(local.split, 0, local.len)
  hep  = join("/", concat(local.slice,[var.vNet.subnet_name_test] ) )
}


output "split" {
  value = local.split
}

output "slice" {
  value = local.slice
}


output "join" {
  value = local.hep
}

output "subnet" {
  value = "${module.network.vnetID}/subnets/${var.vNet.subnet_name_test}"
}