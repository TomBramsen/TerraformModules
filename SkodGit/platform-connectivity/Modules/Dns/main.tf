## Create a Private DNS Zone and link all supplied networks to the zone, so that they can create records in zone

resource "azurerm_private_dns_zone" "azure_dns_zone" {
  name                  = var.dns_zone_name
  resource_group_name   = var.resource_group_name
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "azure_hub_links" {
  count                 = length( var.link_networks )
  name                  = "vnet-link-${count.index}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.azure_dns_zone.name
  virtual_network_id    = var.link_networks[count.index]
}
