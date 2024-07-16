# Please note that subnet list does not nessesary come out in the order they are provided as input
# So if you need to reference a specific subnet, do it like this :
#   subnetID = "${module.network.vnetID}/subnets/${var.SubnetName}"
 output "subnetID" {
  value = [ for subnet in azurerm_subnet.subnets : subnet.id ]
 }

 output "vnetID" {
  value                = azurerm_virtual_network.net.id
 }