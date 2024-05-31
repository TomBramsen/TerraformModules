variable "location" {
  type = string
  default = "westeurope"
}

variable "tags" {
  type        = map(any)
}

variable "rg_name" {
  type        = string
  description = "Name of resource group"
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
  type             = string 
  default          = "mssadministrator"
  description      = "MS SQL Admin user"
}

variable "adminPSW" {
  type             = string 
  default          = ""
  description      = "MS SQL Admin Password.  If blank, a random password will be created"
}

variable "SQLversion" {
  default          = "12.0"
  description      = "SQL Version.  Update this will create new resource!"
}

variable "privateEndpointSubnet" {
  type         = list(string)
  default      = []
  description  = "A list of subnets to create endpoints in.  Leave blank for no private endpoint"
}

variable "log_analytics_id" {
   type        = string
   default     = "/subscriptions/1b3b25cd-2fb6-4f73-a6f7-c2fc0178ce5d/resourceGroups/logs/providers/Microsoft.OperationalInsights/workspaces/loganalytics" 
   description = "ID for the Log Analytics Workspace to send data to"
   
}

variable "enableAnalyticsMetrics"  {
  type         = bool
  default      = false   
  description  = "Should database send Metrics to Log Analytics Workspace"
}

variable "enableAnalyticsLogs"  {
  type         = bool
  default      = false   
  description  = "Should database send Logs to Log Analytics Workspace"
}