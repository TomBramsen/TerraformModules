

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "ModuleTest"
  tags     = var.tags
 }

 
module "network" {
  source        = "./Modules/network"

  resourcegroup = azurerm_resource_group.rg.name
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


module "storage" {
  source   = "./Modules/Storageaccount"
  location = var.location
  rg_name  =  azurerm_resource_group.rg.name
  tags     = var.tags
  name  = "satest32995xx" 
  containers = [ "con1", "con2"]
  createPrivateEndpoint = true
  privateEndpointSubnet = module.network.subnetID[0]


}
/*

module "kv" {
  source   = "./Modules/keyvault"
  location = var.location
  rg_name =  azurerm_resource_group.rg.name
  tags     = var.tags
  name  = "kvsatest32995xx"
}

module "sql" {
  source   = "./Modules/MSSQL"
  location = var.location
  rg_name =  azurerm_resource_group.rg.name
  tags     = var.tags
  name  = "kvsatest329d95xx"
  subnetId = module.network.subnetID[0]
}
*/
