
variable "location" {
  type = string
  default = "northeurope"
}

variable "tags" {
  type        = map(any)
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

variable "vm_name" {
  type        = string
  description = "Name of Virtual Machine"
}
variable "RBAC_Secrets_Officers_IDs" {
  type        = list(string)
  default     = [  ]
  description = "list of GUID that needs access to update secrets. Github SP gets this role. and Trifork gets read per default"
}


variable "netid" {
  type = string
}

variable "vm_size" {
  type = string
  default = "Standard_B2s"
}


variable "admin_user" {
  type        = string
  default     = "azadmin"
  description = "Name of the default admin user"
}