variable "location" {
  type         = string
  default      = "northeurope"
}

variable "tags" {
  type         = map(any)
  default     = {  
  }
}

variable "rg_name" {
  type         = string
  description  = "Name of resource group"
}

variable "name" {
  type        = string
  description = "Name of the Storage Account. Must be uniqe."
}

## Resource sharing on Blob.  Leave CORS_allowed_origins empty if feature not needed
variable "CORS_allowed_origins" {
  type         = list(string)
  default      = []
}

variable "CORS_allowed_methods" {
  type         = list(string)
  default      = ["GET","HEAD","POST","PUT"]
}

variable "useRBACauth" {
  type         = bool
  default      = false 
  description = "access list vs RBAC.  Use RBAC when possible"
}

variable "RBAC_Contributor_IDs" {
  type         = list(string)
  default      = [  ]
  description  = "list of GUID that needs contributor access to storage. Github SP gets contributor. and Trifork gets read per default"
}

variable "account_tier" {
  type         = string
  default      = "Standard"
}

variable "account_replication_type" {
  type         = string
  default      = "LRS"
}

variable "retention_days" {
  type         = number
  default      = 0
  description  = "If value > 0, Point in time restore + versioning will be enabled"
}

variable "containers" {
  type = list(string)
  default = [  ]
  description = "list of containers to create"
}

## Private endpoint name.  
variable "privateEndpointSubnet" {
  type         = list(string)
  default      = []
  description  = "A list of subnets to create endpoints in.  Leave blank for no private endpoint"
}


variable "public_access" {
  type        = bool
  default     = false
  description = "Is public access to storage account Allow og Deny?"
}

variable "lifecycle_delete_in_containers" {
  type        = list(string)
  default     = [  ]
  description = "Delete contents in containers older than x days.  Leave empty if not relevant"
}

variable "lifecycle_delete_after_days" {
  type        = number
  default     = 30
  description = "Delete contents in containers older than 30 days. Only relevant for specified containers"
}