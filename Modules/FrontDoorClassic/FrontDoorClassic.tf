
#  cname links can give issues when delete/update.
#  workaround  : az feature register --namespace Microsoft.Network --name BypassCnameCheckForCustomDomainDeletion

resource "azurerm_frontdoor" "main" {
  name                = var.name
  resource_group_name = var.rg_name

  frontend_endpoint {
    name                     =  var.endpoint_name
    host_name                = "${var.name}.azurefd.net"
    session_affinity_enabled = false
  }

  frontend_endpoint {
     host_name                    = "dev.bramsen.info" 
     name                         = "dev-bramsen-info" 
     session_affinity_enabled     = false 
  }

  backend_pool_load_balancing {
    name                        = var.load_balancing_settings_name
    sample_size                 = 4
    successful_samples_required = 2
  }

  backend_pool_health_probe {
    name                = var.health_probe_settings_name
    path                = "/"
    protocol            = "Http"
    interval_in_seconds = 120
  }

  backend_pool {
    name = var.front_door_backend_pool_name
    backend {
      address     = var.backend_address
      enabled     = true 
      host_header =  var.backend_address
      http_port   = 80 
      https_port  = 443 
      priority    = 1 
      weight      = 50 
    }

    load_balancing_name = var.load_balancing_settings_name
    health_probe_name   = var.health_probe_settings_name
  }

  backend_pool {
    name = "dev" # var.front_door_backend_pool_name
    backend {
      host_header = var.backend_address
      address     = var.backend_address
      http_port   = 80
      https_port  = 443
      weight      = 50
      priority    = 1
    }

    load_balancing_name = var.load_balancing_settings_name
    health_probe_name   = var.health_probe_settings_name
  }

  backend_pool_settings {
    backend_pools_send_receive_timeout_seconds   = 0
    enforce_backend_pools_certificate_name_check = false
  }

  routing_rule {
    name               = var.front_door_routing_rule_name
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [ var.endpoint_name ]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = var.front_door_backend_pool_name
    }
  }

  routing_rule {
    name               = "rule2dev"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [ "dev-bramsen-info" ]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "dev"
    }
  }
}