variable "location"          { default = "northeurope" }
variable "prefix"            { default = "" }
variable "environment"       { default = "dev" }
variable "region"            { default = "neu" }
variable "solutionName"      { default = "Connectivity" }
variable "solutionShortName" { default = "" }


#    address_space         = "10.52.0.0/21"
variable "tags" {
  type = map(any)
  default = {
    environment = "Test"
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
    subnet_appgw_name            = string
    subnet_appgw_prefixes        = list(string)
    subnet_bastion_name          = string
    subnet_bastion_prefixes      = list(string)
   })
  default = {
    rg_name                      = "rg-conn"
    name                         = "connectivity"
    address_space                = [ "10.52.4.0/22" ]
    subnet_name                  = "subnet-conn"
    subnet_address_prefixes      = [ "10.52.4.0/24" ] 
    subnet_appgw_name            = "subnet-appGwSubnet"
    subnet_appgw_prefixes        = [ "10.52.5.64/27" ] 
    subnet_bastion_name          = "AzureBastionSubnet"
    subnet_bastion_prefixes      = [ "10.52.5.0/27" ] 
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
    address_space         = "10.52.0.0/24"
    sku                   = "Standard"
 }
}


##
## VPN for connecting
##
variable "vpn_config" {
  type = object({
    name              = string   
   })
  default = {
    name              = "vpn"
  }
}

##  List of VPN sites
variable "vpn_sites" {
  type = list(object({
    name                     = string
    remote_ip                = string
    cidr                     = string
    kv_secret                = string
    vpn_speed_mpbs           = string 
    encryption_algorithm     = string
    integrity_algorithm      = string
    ike_encryption_algorithm = string
    ike_integrity_algorithm  = string
    dh_group                 = string
    pfs_group                = string
    policy_based_selector    = bool
    sa_lifetime_sec          = number
    sa_data_size_kb          = number
    key                      = string

  }))
    default = [ 
    {
      name                     = "LH-Test"
      remote_ip                = "212.37.143.141"
      cidr                     = "10.35.228.0/24"
      kv_secret                = "vpn-lh-test"
      vpn_speed_mpbs           = "100"
      encryption_algorithm     = "AES256"
      integrity_algorithm      = "SHA256"
      ike_encryption_algorithm = "AES256"
      ike_integrity_algorithm  = "SHA256"
      dh_group                 = "DHGroup14" 
      pfs_group                = "None" 
      policy_based_selector    = true
      sa_lifetime_sec          = 27000
      sa_data_size_kb          = 102400000
      key                      = "DHzUAp!vKiM#e5gR5EXP-NEWrwLf2023"
    }
  ]
}
