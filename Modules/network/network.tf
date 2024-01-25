resource "azurerm_virtual_network" "net" {
  name                = var.name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resourcegroup
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet } 
 
  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = each.value.ip_range
  resource_group_name  = var.resourcegroup
 }

 output "subnetID" {
  value = [ for subnet in azurerm_subnet.subnets : subnet.id ]
 }

 output "vnetID" {
  value = azurerm_virtual_network.net.id
 }