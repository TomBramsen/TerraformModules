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
  default     = true
  description = "Should module create esource group. if false rg_name is referring to existing resource group" 
}

variable "serverName" {
  type        = string
  description = "Name of server for database. Must be uniq.  Environment name will be added in the end"
}

variable "dbName" {
  type     = string
}

variable "sku" {
  type     = string
  default  = "B_Standard_B1ms"
}

variable "dbversion" {
  type     = number
  default  = 14
}

variable "backup_retention_days" {
  type = number
  default = 7
  description = "number of days for retension. Default is 7, can be extended to 35"
}

variable "geo_redundant_backup" {
  type     = bool
  default  = false
}

variable "storage_mb" {
  type     = number
  default  = 32768
}

variable "adminUser" {
  type     = string  
  default  = "psqladmin"
}

variable "adminPsw" {
  type     = string
}

variable "zone" {
  type     = number
  default  = 1
}
   