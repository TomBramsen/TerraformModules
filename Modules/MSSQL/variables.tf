variable "location" {
  type = string
  default = "northeurope"
}

variable "tags" {
  type = map(any)
}

variable "rg_name" {
  type        = string
  description = "Name of resource group"
}

variable "create_rg_group" {
  type        = bool
  default     = false
  description = "Should module create esource group. if false rg_name is referring to existing resource group" 
}

variable "name" {
  type        = string
  description = "Name of server for database. Must be uniq.  Environment name will be added in the end"
}

variable "databases" {
  type        = list(string)
  default     = [ "Database" ]
  description = "List of databases that needs to be created.  "
}

variable "adminId" {
  type = string 
  default = "mssadministrator"
}


variable "createPrivateEndpoint" {
  type         = bool
  default      = false
  description = "Should private endpoint be created?  If so, specify subnet to link to"
}
variable "privateEndpointSubnet" {
  type         = string
  default      = ""
  description  = "Must be specified if createPrivateEndpoint is true, otherwise leace it blank"
}
variable "privateEndpointIp" {
  type         = string
  default      = ""
  description  = "Must be specified if createPrivateEndpoint is true, otherwise leace it blank"
  ## Option to use dynamic ip should be implemented
}

variable "subnetId" {
  type = string
  default = ""
}