variable "location"          { default = "northeurope" }
variable "prefix"            { default = "lh" }
variable "environment"       { default = "dev" }
variable "region"            { default = "neu" }
variable "solutionName"      { default = "management" }
variable "solutionShortName" { default = "mgmt" }

variable "tags" {
  type = map(any)
  default = {
    environment = "Prod"
    owner       = "LH"
  } 
}
variable "tagsVM" {
  type = map(any)
  default = {
    environment  = "Prod"
    owner        = "LH"
    autodelete   = "false"
    AutoShutDown = "20:30"
    AutoStart    = "07:00"
    Automation   = "True"
  } 
}

variable "resource_group_name" {
 type        = string
 description = "Name of the resource group"
 default     = "rg-IoT"
}

variable "acr_name" {
 type        = string
 description = "Name of the azure container registry"
 default     = "lhAcr"
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
  

variable "dps_name" {
 type        = string
 description = "Name of the device provisioning service"
 default     = "dps"
}

variable "unity_builds_storage_account_name" {
   type        = string
   description = "Name of the storage account used for unity builds"
   default     = "unityBuildsManagementNeu"
}


variable "general_storage_account_name" {
 type = object({
    name                    = string
    containers              = list(string)
    })
  default = {
    name                 = "lhsharedstorageneu"
    containers           = [ "robolab",      
                             "storylab",
                             "hamlet",
                             "experiencehub",
                             "mosaik"                
                           ]
   }
}



####   Management network

variable "management_vnet_config" {
    type = object({
    rg_name                 = string
    name                    = string
    address_space           = list(string)
    })
  default = {
    rg_name                 = "rg-mgmt"
    name                    = "vnet-mgmt"
    address_space           = [ "10.43.0.0/21" ]
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

variable "bastion_config" {
   type = object({
    rg_name                 = string
    name                    = string
    pip_name                = string
   })
  default = {
    rg_name                 = "rg-bastion"
    name                    = "bastion"
    pip_name                = "pip-bast"
   }
}

variable "win_jump_config" {
   type = object({
    rg_name                 = string
    name                    = string
    pip_name                = string
    address_space           = list(string)
    size                    = string
    })
  default = {
    rg_name                 = "rg-winjump"
    name                    = "jmp"
    pip_name                = "pip-bast"
    address_space           = [ "10.43.0.0/22" ]
    size                    = "Standard_D2s_v3"
   }
}

variable "win_sch_config" {
   type = object({
    rg_name                 = string
    name                    = string
    size                    = string 
    })
  default = {
    rg_name                 = "rg-wm-scheduledtasks"
    name                    = "vm-sch"
    size                    = "Standard_DS1_v2"
   }
}




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


variable "azure_keyvault_config" {
   type = object({
    rg_name                 = string
    name                    = string
    sku                     = string

    })
  default = {
      rg_name                 = "rg-kv"
      name                    = "keyvault"
      sku                     = "standard"
      }
}