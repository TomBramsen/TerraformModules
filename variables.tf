variable "location"          { default = "westeurope" }
variable "prefix"            { default = "" }
variable "environment"       { default = "dev" }
variable "region"            { default = "neu" }
variable "solutionName"      { default = "connectivity" }
variable "solutionShortName" { default = "conn" }

variable "tags" {
  type = map(any)
  default = {
    environment = "leg"
  }
}


# Network settings for connectivity network
variable "connectivity_vnet_config" {
   type = object({
    rg_name                      = string
    name                         = string
    address_space                = list(string)
    subnet_name                  = string
    subnet_address_prefixes      = list(string)
    subnet_dns_inbound_name      = string
    subnet_dns_inbound_prefixes  = list(string)
    subnet_dns_outbound_name     = string
    subnet_dns_outbound_prefixes = list(string)
    subnet_appgw_Front_name      = string
    subnet_appgw_Front_prefixes  = list(string)
    subnet_appgw_Back_name       = string
    subnet_appgw_Back_prefixes   = list(string)  
   })
  default = {
    rg_name                      = "rg-conn"
    name                         = "connectivity"
    address_space                = [ "10.42.8.0/23" ]
    subnet_name                  = "subnet-conn"
    subnet_address_prefixes      = [ "10.42.8.0/24" ] 
    subnet_dns_inbound_name      = "subnet-dns-inbound"
    subnet_dns_inbound_prefixes  = [ "10.42.9.0/27" ] 
    subnet_dns_outbound_name     = "subnet-dns-outbound"
    subnet_dns_outbound_prefixes = [ "10.42.9.32/27" ]  
    subnet_appgw_Front_name      = "subnet-appgwFrontSubnet"
    subnet_appgw_Front_prefixes  = [ "10.42.9.64/27" ] 
    subnet_appgw_Back_name       = "subnet-appgwBackSubnet"
    subnet_appgw_Back_prefixes   = [ "10.42.9.96/27" ]  
  }
}

# Virtual vwan definition and tier
variable "vwan_config" {
  type = object({
    rg_name               = string
    name                  = string
    sku                   = string
  })
  default = {
    rg_name               = "rg-vwan"
    name                  = "vwan-01"
    sku                   = "Standard"
  }
}

# Hub configuration.  
variable "vwan_hub_config" {
  type = object({
    name                  = string
    address_space         = string
    sku                   = string
   })
  default = {
    name                  = "vwan-hub-01"
    address_space         = "10.42.0.0/21"
    sku                   = "Standard"
 }
}


# # Private dns a records - dev
variable "private_dns_records_dev" {
  type = list(object({
    a_record          = string
    target_ip         = string
   }))
  default = [
    {  
       a_record          = "robolab"
      target_ip         = "10.41.0.4"   # kluster-dev/kubernetes-internal
    } 
  ]
}

# Firewall name and tier
variable "fw_config" {
  type = object({
    name = string
    sku = object({
      tier = string
      name = string
    })
  })
  default = {
    name = "fw_01"
    sku = {
      name = "AZFW_Hub"
      tier = "Standard"
    }
  }
}

# Azure firewall policy
variable "fw_pol_config" {
  type = object({
    name          = string
    cluster_cidrs = list(string)
  })
  default = {
    name = "fw01"
    cluster_cidrs = [ "10.40.0.0/16","10.41.0.0/16" ] 
  }
}


# Log Analytics settings
variable "log_config" {
  type = object({
    retention    = number
    id           = string
  })
  default = {
    retention    = 7
    id           = "/subscriptions/b2b43e30-7abd-4d22-80be-cbf9bebd9ac1/resourceGroups/rg-log-management-neu/providers/Microsoft.OperationalInsights/workspaces/log-management-neu"
  }
}

##
## DNS Zones
##

# # Private DNS Zone for Development / Production & Core (Resources available for both dev & prod)
variable "dns_zones_config" {
  type = object({
    rg_name           = string
    dev_dns_zone      = string   
    prod_dns_zone     = string
    core_dns_zone     = string
    dns_resolver_name = string
    dns_inbound_name  = string
    dns_outbound_name = string    
  })
  default = {
    rg_name           = "rg-dns"
    dev_dns_zone      = "dev.lhexperience.dk"
    prod_dns_zone     = "prod.lhexperience.dk"
    core_dns_zone     = "core.lhexperience.dk"
    dns_resolver_name = "dns-resolver"
    dns_inbound_name  = "dns-inbound"
    dns_outbound_name = "dns-outbound"
  }
}

# AppGW configuration.  
variable "appgw_hub_config" {
  type = object({
    rg_name               = string
    name                  = string
    pip_name              = string
    private_ip_name       = string
    gw_ip_conf_name       = string
    backend_adr_pool_name = string
    backend_http_settings = string
    http_listener_name    = string
    frontend_port_name    = string
    frontend_port         = number
    protocol              = string
    protocol_backend      = string
    address_space         = string
    routing_rule_name     = string
    sku = object({
      name                = string
      tier                = string
      capacity            = number
    })
    prodsite =object({
      name                = string
      hostname            = string
      ip_addresses        = list(string)
    })
    devsite =object({
      name                = string
      hostname            = string
      ip_addresses        = list(string)
    })
    })
  default = {
    rg_name               = "rg-appgw"
    name                  = "appgw-01"
    pip_name              = "pip-appgw"
    private_ip_name       = "private-ip-appgw"
    gw_ip_conf_name       = "appgw-ip-conf"
    backend_adr_pool_name = "backend_pool"
    backend_http_settings = "backend_http_settings"
    http_listener_name    = "http-listener"
    frontend_port_name    = "frontend"
    frontend_port         = 80
    protocol              = "Http"
    protocol_backend      = "Http"
    address_space         = "10.42.0.0/21"
    routing_rule_name     = "routing-rule"
    sku = {
      name                = "Standard_v2"
      tier                = "Standard_v2"
      capacity            = 2
    }
    prodsite = {
      name                = "prodsite"
      hostname            = "prod.lh"
      ip_addresses        = [ "10.0.0.1"]
    }
    devsite = {
      name                = "devsite"
      hostname            = "dev.lh"
      ip_addresses        = [ "10.0.0.2"]
    }
  }
}

variable "management_vnet_subnets" {
   type = map(any)
   default = {
     subnet_1 = {
        name                = "subnet-default"
        address_prefixes    = [ "10.43.1.0/24" ]
     }
     jumphost_win = {
        name                = "subnet-jumphost"
        address_prefixes    = [ "10.43.2.0/24" ]
     }
     bastion_subnet = {
        name                = "AzureBastionSubnet"
        address_prefixes    = [ "10.43.3.0/24" ]
     }
  }
}



# Azure Container Registry
variable "acr_config" {
  type = object({
    name          = string
    rg_name       = string
  })
  default = {
    name = "acr"
    rg_name = "acrRG"
  }
}

# List of scope maps on ACR regostry
variable "acr_scope_map" { 
  type                   = map
  default = { 
   "platformservices"    = "helm/platform-services"
   "cityarchitect"       = "helm/experience-city-architect" 
   "experiencehub"       = "helm/experience-hub" 
  } 
}
  

variable "win_jump_config" {
   type = object({
    count                   = number
    rg_name                 = string
    name                    = string
    vnet_name               = string
    subnet_name             = string
    pip_name                = string
    vm_size                 = string
   vnet_address_space       = list(string)
   subnet_address_space     = list(string)
    })
  default = {
    count                   = 5
    rg_name                 = "rg-winjump"
    name                    = "jmp"
    vnet_name               = "vnet-jmp"
    subnet_name             = "vsubnet-jmp"
    pip_name                = "pip-bast"
    vm_size                 = "Standard_B2s"
   vnet_address_space       = [ "10.43.0.0/22" ]
   subnet_address_space     = [ "10.43.1.0/24" ]
   }
}


variable  apache_web_config {
  default = {
    count                 = 1
    prefix                = "apache"
   resource_group_name    = "Apache"
   location               = "northeurope"
   virtual_network_name   = "vnet"
   address_space          = ["10.103.0.0/16"]
   subnet_prefix          = ["10.103.2.0/24"]
   hostname               = "vmtf"
   vm_size                = "Standard_B2s"
   image_publisher        = "Canonical"
   image_offer            = "0001-com-ubuntu-server-jammy"
   image_sku              = "22_04-lts-gen2"
   image_version          = "latest"
   admin_username         = "adminuser"
   admin_password         = "Kodeord1!"
  }
}


# DNS Records that are shared among experiences
variable "private_dns_records" {
   type = list(object({
    name                    = string
    dev_ip                  = string  
    prod_ip                 = string
    }))
  default = [ {  
      name              = "rabbitmq"
      dev_ip            = "10.41.0.5" 
      prod_ip           = "10.44.0.5"   
    },
    {  
      name              = "otel.monitoring"
      dev_ip            = "10.41.0.4" 
      prod_ip           = "10.44.0.4" 
    },
    {  
      name              = "grafana.monitoring"
      dev_ip            = "10.41.0.4" 
      prod_ip           = "10.44.0.4"   
    },
    {  
      name              = "memories"
      dev_ip            = "10.37.128.254" 
      prod_ip           = "10.37.128.254"   
    }
  ]
}
