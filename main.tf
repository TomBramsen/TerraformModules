

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
  address_space = ["10.52.1.0/24"]
  subnets       = [
   {
      name      = "subnetVPNRange"  
      ip_range  = ["10.52.1.0/24"]
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

/*
module "storage" {
  source                = "./Modules/Storageaccount"
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
*/

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