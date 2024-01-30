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

## Resource sharing on Blob.  Leave CORS_allowed_origins empty if feature not needed
variable "CORS_allowed_origins" {
  type = list(string)
  default = []
}

variable "CORS_allowed_methods" {
  type = list(string)
  default = ["GET","HEAD","POST","PUT"]
}

variable "useRBACauth" {
  type         = bool
  default      = false # true
  description = "access list vs RBAC.  Use RBAC when possible"
}

variable "RBAC_Contributor_IDs" {
  type = list(string)
  default = [  ]
  description = "list of GUID that needs contributor access to storage. Github SP gets contributor. and Trifork gets read per default"
}

variable "account_tier" {
  type = string
  default = "Standard"
}

variable "account_replication_type" {
  type = string
  default = "LRS"
}

variable "pointInTimeRestore" {
  type     = bool
  default  = true
}

variable "containers" {
  type = list(string)
  default = [  ]
  description = "list of containers to create"
}

## Private endpoint name.  Leave blank if endpoint not needed
variable "privateEndpointSubnet" {
  type         = string
  default      = ""
  description  = "Must be specified if createPrivateEndpoint is true, otherwise leace it blank"
}

variable "subnetId" {
  type = string
  default = ""
}