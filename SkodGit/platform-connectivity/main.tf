/*
Deploys Conectivity subscription with Virtual WAN, Firewall etc

Three areas needs to updated continuesly :
  Network peerings when new experiances are created
  DNS Peerings
  Firewall rules
*/

locals{
  name_postfix_short = "${var.solutionShortName}-${var.region}"
  name_postfix       = "${var.solutionName}-${var.region}"
 }

##   
##    Network for general items in subscription
##    Create generel subnet + 2 subnet for private dns resolver : inbound & outbound dns queries

##
resource "azurerm_resource_group" "connectivityRg" {
  location = var.location
  name     = lower("${var.connectivity_vnet_config.rg_name}-${local.name_postfix}")
  tags     = var.tags
}

resource "azurerm_virtual_network" "conectivityVnet" {
  name                = lower("${var.connectivity_vnet_config.name}-${local.name_postfix}")
  address_space       = var.connectivity_vnet_config.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivityRg.name
  tags                = var.tags
}

resource "azurerm_subnet" "conectivitySubnet" {
  name                 = lower("${var.connectivity_vnet_config.subnet_name}-${local.name_postfix}")
  virtual_network_name = azurerm_virtual_network.conectivityVnet.name
  address_prefixes     = var.connectivity_vnet_config.subnet_address_prefixes
  resource_group_name  = azurerm_resource_group.connectivityRg.name
 }

 resource "azurerm_subnet" "appGwSubnet" {
  name                = var.connectivity_vnet_config.subnet_appgw_name
  virtual_network_name = azurerm_virtual_network.conectivityVnet.name
  address_prefixes       =  var.connectivity_vnet_config.subnet_appgw_prefixes
  resource_group_name = azurerm_resource_group.connectivityRg.name
 
}
 resource "azurerm_subnet" "BastionSubnet" {
  name                = var.connectivity_vnet_config.subnet_bastion_name
  virtual_network_name = azurerm_virtual_network.conectivityVnet.name
  address_prefixes       =  var.connectivity_vnet_config.subnet_bastion_prefixes
  resource_group_name = azurerm_resource_group.connectivityRg.name
 
}
##   
##    VWAN
##
resource "azurerm_resource_group" "vwanRg" {
  location = var.location
  name     = lower("${var.vwan_config.rg_name}-${local.name_postfix}")
  tags     = var.tags
 }
resource "azurerm_virtual_wan" "vwan01" {
  name                           = lower("${var.vwan_config.name}-${local.name_postfix}")
  resource_group_name            = azurerm_resource_group.vwanRg.name
  location                       = var.location
  type                           = var.vwan_config.sku
  allow_branch_to_branch_traffic = true
  tags                           = var.tags
}
resource "azurerm_virtual_hub" "vhub01" {
  name                = lower("${var.vwan_hub_config.name}-${local.name_postfix}")
  resource_group_name = azurerm_resource_group.vwanRg.name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.vwan01.id
  address_prefix      = var.vwan_hub_config.address_space
  tags                = var.tags
}

##
##  Peering 
##
resource "azurerm_virtual_hub_connection" "peering" {
  #for_each = { for peer in var.vwan_peerings : peer.name => peer } 
  name                      = "wvan_peering" # each.value.name
  virtual_hub_id            = azurerm_virtual_hub.vhub01.id
  remote_virtual_network_id = azurerm_virtual_network.conectivityVnet.id #  " each.value.vnet_id
  /*routing {
    propagated_route_table {
        # Route by direct route table for private traffic
         # route_table_ids = [ azurerm_virtual_hub.vhub01.default_route_table_id  ]
         # labels          = [] // [  "default"]

      # Route private traffic by FW
       route_table_ids = [ "${azurerm_virtual_hub.vhub01.id}/hubRouteTables/noneRouteTable"]
       labels = ["none"] 
     }
  }
  */
}


## VM
##
module "VMModule" {
  source         = "./Modules/Vm"
  location       = var.location
  tags           = var.tags
  rg_name        = "rg-vm"
  vm_name        = "vm-test"
  netid          = azurerm_subnet.conectivitySubnet.id
}



##
##     Bastion
##

resource "azurerm_resource_group" "bastionRg" {
  name                   = "rg-bastion"
  location               = var.location
  tags                   = var.tags
 }

 resource "azurerm_public_ip" "bastionPip" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivityRg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "bastion" {
  name                   = "host-bastion"
  location               = azurerm_resource_group.bastionRg.location
  resource_group_name    = azurerm_resource_group.bastionRg.name
  tags                   = var.tags
  sku                    = "Basic"

  ip_configuration {
    name                 = "ipconfig-bastion"
    subnet_id            = azurerm_subnet.BastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastionPip.id
  }
}
