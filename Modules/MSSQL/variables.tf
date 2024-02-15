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
  type                    = list(object({
    name                     = string
    sku_name                 = optional(string, "S0")
    zone_redundant           = optional(bool, false)
    geo_backup_enabled       = optional(bool, false) 
    size                     = optional(number, 50)
    retention_enabled        = optional(bool, true)
    retention_days           = optional(number, 7)      # 1-35 allowed
    backup_interval_in_hours = optional(number, 24)     # only 12 or 24 allowed
    monthly_retention        = optional(string, "P3M")  # Past 3 months
    week_of_year             = optional(number, 1)      # Week of year for yearly backup
    weekly_retention         = optional(string, "P4W")  # Past 4 weeks
    yearly_retention         = optional(string, "PT0S") # none
  }))
  default                    = [ ]
  description                = "List of databases that needs to be created.  "
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

variable "public_access" {
  type         = bool
  default      = false
  description  = "Is public access to storage account Allow og Deny?"
}