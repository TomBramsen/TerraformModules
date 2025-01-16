resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = var.name
  resource_group_name = var.rg_name
  sku_name            = var.sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoints" {
  count                    = length(var.endpoints)
  name                     = "${var.endpoints[count.index]}" 
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  count                    = length(var.endpoints) 
  name                     = "${var.prefix}-origingroup-${var.endpoints[count.index]}" 
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 1
    successful_samples_required = 1
  }

  health_probe {
    path                = "/healtz"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "my_app_service_origin" {
  count                          = length(var.endpoints) #
  name                           = "${var.prefix}-origin-${var.endpoints[count.index]}" 
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.my_origin_group[count.index].id
  
  certificate_name_check_enabled = false
  enabled                        = true
  host_name                      = var.originheaders[count.index]
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.originheaders[count.index]
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  count = length(var.endpoints)
  name = "${var.prefix}-route-${var.endpoints[count.index]}" 
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoints[count.index].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group[count.index].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.my_app_service_origin[count.index].id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

/*


resource "azurerm_cdn_frontdoor_firewall_policy" "WAFpolicy" {
  count               = var.applyWAF ? 0  : 1
  mode                = var.WAFmode
  name                = "WAFpolicy"
  resource_group_name = "bli-shared-app-dz-eu"
  sku_name            = "Standard_AzureFrontDoor"  # Premium_AzureFrontDoor
  custom_rule {
    action               = "Block"
    name                 = "OnlyAllowSpecificIP"
    priority             = 1000
    rate_limit_threshold = 100
    type                 = "MatchRule"
    match_condition {
     match_values       = [  "217.74.148.94"   ]
     operator           = "IPMatch" 
     match_variable     = "RemoteAddr"
  }
}
}


resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
    count               = var.applyWAF ? 0  : 1

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  name                     = "fd-securitypol-01"
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.WAFpolicy[0].id
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoints[0].id
        }
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoints[1].id
        }
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoints[2].id
        }
      }
    }
  }
}


*/
