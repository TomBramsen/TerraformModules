# Creates an VPN on the Virtual WAN for connecting Lego House and Trifork locations
#
#

resource "azurerm_vpn_gateway" "vpnGateway" {
  name                         = lower("${var.vpn_config.name}-${local.name_postfix}") 
  location                     = var.location
  resource_group_name          = azurerm_resource_group.vwanRg.name
  virtual_hub_id               = azurerm_virtual_hub.vhub01.id
  scale_unit                   = 2
  tags                         = var.tags
}

##
## Set up VPN
##
resource "azurerm_vpn_site" "vpnSite" {
  count                        = length(var.vpn_sites)
  name                         = lower("vpn-site-${var.vpn_sites[count.index].name}-${local.name_postfix}")
  location                     = var.location
  resource_group_name          = azurerm_resource_group.vwanRg.name
  virtual_wan_id               = azurerm_virtual_wan.vwan01.id
  address_cidrs                = [ var.vpn_sites[count.index].cidr ]
  link {
    name                       = lower("vpn-link-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    ip_address                 = var.vpn_sites[count.index].remote_ip
    speed_in_mbps              = var.vpn_sites[count.index].vpn_speed_mpbs
  }
}



resource "azurerm_vpn_site" "vpnbgp" {
  address_cidrs       = ["10.35.228.0/24"]
  location            = "northeurope"
  name                = "vpn-site-lh-test-connectivity-neu"
  resource_group_name = "rg-vwan-connectivity-neu"
  virtual_wan_id      = "/subscriptions/0d7ee0d7-f9e4-4089-bcc1-f0cfeacb104c/resourceGroups/rg-vwan-connectivity-neu/providers/Microsoft.Network/virtualWans/vwan-01-connectivity-neu"
  link {
    ip_address    = "212.37.143.141"
    name          = "vpn-link-lh-test-connectivity-neu"
    speed_in_mbps = 100
  }
}

resource "azurerm_vpn_gateway_connection" "vpnConnection" {
  count                        = length(var.vpn_sites)
  name                         = lower("vpn-conn-${var.vpn_sites[count.index].name}-${local.name_postfix}")
  vpn_gateway_id               = azurerm_vpn_gateway.vpnGateway.id
  remote_vpn_site_id           = azurerm_vpn_site.vpnSite[count.index].id
  
  vpn_link {
    name                       = lower("vpn-conn-link-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    vpn_site_link_id           = azurerm_vpn_site.vpnSite[count.index].link[0].id
    shared_key                 = var.vpn_sites[count.index].key
    policy_based_traffic_selector_enabled = var.vpn_sites[count.index].policy_based_selector
    protocol                   = "IKEv2"
    ipsec_policy {
      encryption_algorithm     = var.vpn_sites[count.index].encryption_algorithm
      integrity_algorithm      = var.vpn_sites[count.index].integrity_algorithm
      ike_encryption_algorithm = var.vpn_sites[count.index].ike_encryption_algorithm
      ike_integrity_algorithm  = var.vpn_sites[count.index].ike_integrity_algorithm
      dh_group                 = var.vpn_sites[count.index].dh_group
      pfs_group                = var.vpn_sites[count.index].pfs_group
      sa_lifetime_sec          = var.vpn_sites[count.index].sa_lifetime_sec
      sa_data_size_kb          = var.vpn_sites[count.index].sa_data_size_kb
   }
  }
}


resource "azurerm_vpn_gateway_connection" "vpnConnectionBGP" {
  name                         = "vpn-bgp"
  vpn_gateway_id               = azurerm_vpn_gateway.vpnGateway.id
  remote_vpn_site_id           = azurerm_vpn_site.vpnbgp.id
  
  vpn_link {
    name                       = "vpn-conn-link-BGP"
    vpn_site_link_id           = azurerm_vpn_site.vpnbgp.link[0].id
    shared_key                 = var.vpn_sites[0].key
    policy_based_traffic_selector_enabled = var.vpn_sites[0].policy_based_selector
    protocol                   = "IKEv2"
    ipsec_policy {
      encryption_algorithm     = var.vpn_sites[0].encryption_algorithm
      integrity_algorithm      = var.vpn_sites[0].integrity_algorithm
      ike_encryption_algorithm = var.vpn_sites[0].ike_encryption_algorithm
      ike_integrity_algorithm  = var.vpn_sites[0].ike_integrity_algorithm
      dh_group                 = var.vpn_sites[0].dh_group
      pfs_group                = var.vpn_sites[0].pfs_group
      sa_lifetime_sec          = var.vpn_sites[0].sa_lifetime_sec
      sa_data_size_kb          = var.vpn_sites[0].sa_data_size_kb
   }
  }
}
