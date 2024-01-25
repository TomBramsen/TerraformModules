

resource "azurerm_resource_group" "VMtest" {
  location = var.location
  name     = "Testnet1"
  tags     = var.tags
 }

 
module "network" {
  source        = "./Modules/network"

  resourcegroup = azurerm_resource_group.VMtest.name
  location      = azurerm_resource_group.VMtest.location
  name          = "NetVPNrange_net1"
  address_space = ["10.52.1.0/24"]
  subnets       = [
   {
      name      = "subnetVPNRange"  
      ip_range  = ["10.52.1.0/24"]
   }
  ]
}

module "vm" {
  source        = "./Modules/Vm"

  resourcegroup = azurerm_resource_group.VMtest.name
  location      = azurerm_resource_group.VMtest.location
  name          = "TestVM1"
  netid         = module.network.subnetID[0]
  vm_size       = "Standard_B2s"
}


// Net 2

resource "azurerm_resource_group" "VMtest2" {
  location = var.location
  name     = "Testnet2"
  tags     = var.tags
 }

 
module "network2" {
  source        = "./Modules/network"

  resourcegroup = azurerm_resource_group.VMtest2.name
  location      = azurerm_resource_group.VMtest2.location
  name          = "NetVPNrange_net2"
  address_space = ["10.53.0.0/21"]
  subnets       = [
   {
      name      = "subnetVPNRange"  
      ip_range  = ["10.53.1.0/24"]
   }
  ]
}

module "vm2" {
  source        = "./Modules/Vm"

  resourcegroup = azurerm_resource_group.VMtest2.name
  location      = azurerm_resource_group.VMtest2.location
  name          = "TestVM2"
  netid         = module.network2.subnetID[0]
  vm_size       = "Standard_B2s"
}



module "storage" {
  source   = "./Modules/Storageaccount"
  location = var.location
  rg_name  = "rg-StorageAcc"
  tags     = var.tags
  sa_name  = "satest32995xx" 
  containers = [ "con1", "con2"]
}


module "kv" {
  source   = "./Modules/keyvault"
  location = var.location
  resourcegroup =  "rg-StorageAcc"
  tags     = var.tags
  name  = "kvsatest32995xx"
}

