
variable "location" {
  type         = string
  default      = "northeurope"
}

variable "tags" {
  type         = map(any)
  default = {  }
}

variable "rg_name" {
  type         = string
  description  = "Name of resource group"
}


variable "prefix" {
  type         = string  
  default      = ""
}

variable "name" {
   default      = "afd-frontdoor" // "afd-${lower(random_id.front_door_name.hex)}"
   type         = string
}

variable "endpoints" {
   default      = ["endpoint-frontdoor"] 
   type         = list(string)
   description = "Frontdoor Domains"
}

variable "originheaders" {
   default      = ["origin-headers"] 
   type         = list(string)
  
}

variable "sku_name" {
  type = string
  default = "Standard_AzureFrontDoor"
}


variable "WAFpolicy" {
  type = string
  default = ""
}

variable "applyWAF" {
  type = bool
  default = false
}

variable "WAFmode" {
  type = string 
  default = "Detection"  # Prevention
}
