variable "location"          { default = "northeurope" }
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


variable "databases" {
   type = list(object({
       name                     = string
       size                     = number
       retention_enabled        = bool   
       sku_name                 = string
       backup_interval_in_hours = number
       monthly_retention        = string
       week_of_year             = number
       weekly_retention         = string
       yearly_retention         = string
  }))
   default =  [
      {
      name                     = "kvsatest329d95xlx"
      size                     = 50
      retention_enabled        = false
      sku_name                 = "S0"
      backup_interval_in_hours = 24
      monthly_retention        = "P3M"
      week_of_year             = 1
      weekly_retention         = "P4W"
      yearly_retention         = "PT0S"
      }
   ]
}



# Log Analytics settings
variable "azure_log_analytics_config" {
   type = object({
    rg_name                 = string
    name                    = string
    retention_in_days       = number
    sku                     = string
    })
  default = {
      rg_name                 = "rg-log"
      name                    = "log"
      retention_in_days       = 30
      sku                     = "PerGB2018"
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
  



variable "subnets" {
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


# Network settings 
variable "vNet" {
   type = object({
    address_space          = list(string)
    name                   = string
    subnet_ip_shared       = list(string)
    subnet_name_shared     = string
    subnet_ip_devicemgmt   = list(string)
    subnet_name_devicemgmt = string,
    subnet_ip_test         = list(string)
    subnet_name_test       = string
    })
    default = {
    address_space            = ["10.179.16.0/20"]
    name                     = "vnet-platform-services-dev"
    subnet_ip_shared         = ["10.179.16.0/24"]
    subnet_name_shared       = "subnet-shared-dev"
    subnet_ip_devicemgmt     = ["10.179.17.0/25"]  
    subnet_name_devicemgmt   = "subnet-devicemgmt-dev",
    subnet_ip_test           = ["10.179.17.128/25"]  
    subnet_name_test         = "subnet-test-dev"
  }
}
