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
  /*
  bgp_settings {
    peer_weight               = 0
    asn                       = 65515 # 65015
    instance_0_bgp_peering_address {
       custom_ips =  [ var.vpn_config.bgp_0_instance ]    # /30 ,dvs 1 og 2
    }
    instance_1_bgp_peering_address {
       custom_ips = [ var.vpn_config.bgp_1_instance ]  # lh 5 og mig 6
    }
  }
  */
  
  
}

##
## Set up VPN  Route/Policy based
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

/*
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

*/


## Set up VPN - BGP Routing

resource "azurerm_vpn_site" "vpnSiteBGP" {
  count               = length(var.vpn_sites_BGP)
  name                = lower("vpn-site-BGP-${var.vpn_sites[count.index].name}-${local.name_postfix}")
  address_cidrs       = [ var.vpn_sites_BGP[count.index].cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.vwanRg.name
  virtual_wan_id      = azurerm_virtual_wan.vwan01.id
  device_vendor       = var.vpn_sites_BGP[count.index].device_vendor
  device_model        = var.vpn_sites_BGP[count.index].device_model
  tags                = var.tags

  link {
    ip_address    = var.vpn_sites_BGP[count.index].remote_ip_addr0
    name          = lower("vpn-link-BGP1-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    speed_in_mbps =  var.vpn_sites_BGP[count.index].vpn_speed_mpbs
  
    bgp {
      asn = "65001"
      peering_address = var.vpn_sites_BGP[count.index].BGP_peering_addr_0 # peering_address = "10.52.0.12" 
    }
  }
  /*
  link {
    ip_address    = var.vpn_sites_BGP[count.index].remote_ip_addr1
    name          = lower("vpn-link-BGP2-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    speed_in_mbps =  var.vpn_sites_BGP[count.index].vpn_speed_mpbs
  
    bgp {
      asn = "65001"
      peering_address = var.vpn_sites_BGP[count.index].BGP_peering_addr_1
    }
  }
  */
}

resource "azurerm_vpn_gateway_connection" "vpnConnectionBGP" {
  count                        = length(var.vpn_sites_BGP)
  name                         = "vpn-bgp"
  vpn_gateway_id               = azurerm_vpn_gateway.vpnGateway.id
  remote_vpn_site_id           = azurerm_vpn_site.vpnSiteBGP[count.index].id
  
  vpn_link {
    name                       = lower("vpn-conn-link-BGP1-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    vpn_site_link_id           = azurerm_vpn_site.vpnSiteBGP[count.index].link[0].id
    shared_key                 = var.vpn_sites[0].key
    bgp_enabled                = true
    protocol                   = "IKEv2"
    
    /*
    custom_bgp_address {
      ip_address               = var.vpn_config.bgp_0_instance #azurerm_vpn_gateway.vpnGateway.bgp_settings[0].bgp_peering_address
      ip_configuration_id      = azurerm_vpn_gateway.vpnGateway.bgp_settings[0].instance_0_bgp_peering_address[0].ip_configuration_id 
    }
    */
    custom_bgp_address {
      ip_address          = var.vpn_config.bgp_0_instance 
      ip_configuration_id = "Instance0"
    }
    custom_bgp_address {
      ip_address          = var.vpn_config.bgp_1_instance 
      ip_configuration_id = "Instance1"
    }
    ipsec_policy {
      encryption_algorithm     = var.vpn_sites_BGP[count.index].encryption_algorithm
      integrity_algorithm      = var.vpn_sites_BGP[count.index].integrity_algorithm
      ike_encryption_algorithm = var.vpn_sites_BGP[count.index].ike_encryption_algorithm
      ike_integrity_algorithm  = var.vpn_sites_BGP[count.index].ike_integrity_algorithm
      dh_group                 = var.vpn_sites_BGP[count.index].dh_group
      pfs_group                = var.vpn_sites_BGP[count.index].pfs_group
      sa_lifetime_sec          = var.vpn_sites_BGP[count.index].sa_lifetime_sec
      sa_data_size_kb          = var.vpn_sites_BGP[count.index].sa_data_size_kb
   }
  }
  
  /*
  vpn_link {
    name                       = lower("vpn-conn-link-BGP2-${var.vpn_sites[count.index].name}-${local.name_postfix}")
    vpn_site_link_id           = azurerm_vpn_site.vpnSiteBGP[count.index].link[0].id
    shared_key                 = var.vpn_sites[0].key
    bgp_enabled                = true
    protocol                   = "IKEv2"
  /*  custom_bgp_address {
      ip_address               = var.vpn_config.bgp_1_instance # "169.254.21.11" # azurerm_vpn_gateway.vpnGateway.bgp_settings[0].bgp_peering_address
      ip_configuration_id      = azurerm_vpn_gateway.vpnGateway.bgp_settings[0].instance_1_bgp_peering_address[0].ip_configuration_id 
      # "Instance0"
    }
    
    ipsec_policy {
      encryption_algorithm     = var.vpn_sites_BGP[count.index].encryption_algorithm
      integrity_algorithm      = var.vpn_sites_BGP[count.index].integrity_algorithm
      ike_encryption_algorithm = var.vpn_sites_BGP[count.index].ike_encryption_algorithm
      ike_integrity_algorithm  = var.vpn_sites_BGP[count.index].ike_integrity_algorithm
      dh_group                 = var.vpn_sites_BGP[count.index].dh_group
      pfs_group                = var.vpn_sites_BGP[count.index].pfs_group
      sa_lifetime_sec          = var.vpn_sites_BGP[count.index].sa_lifetime_sec
      sa_data_size_kb          = var.vpn_sites_BGP[count.index].sa_data_size_kb
   }
  }
  */
}
