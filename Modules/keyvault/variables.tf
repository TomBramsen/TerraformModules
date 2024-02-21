variable "location" {
  type         = string
  default      = "northeurope"
}

variable "tags" {
  type         = map(any)
}

variable "rg_name" {
  type         = string
  description  = "Name of resource group"

}
variable "create_rg_group" {
  type         = bool
  default      = false
  description  = "Should module create resource group. if false rg_name is referring to existing resource group" 
}

variable "name" {
  type         = string
}

variable "sku" {
  type        = string
  default     = "standard"
  description = "Possible values are standard and premium"
}

variable "purge_protection" {
 type          = bool
 default       = false
 description   = "Wth Purge Protection Enabled, Key Vault to be deleted will be deleted after 90 days "
}

variable "RBAC_Secrets_Officers_IDs" {
  type         = list(string)
  default      = [  ]
  description  = "list of GUID that needs access to update secrets. Github SP gets this role. and Trifork gets read per default"
}

variable "secrets" {
  type         = map(string)
  default      = {}
  description  = "List of secrets and key that will be added to Keyvault."
}

variable "enable_rbac_authorization" {
  type         = bool
  default      = true
  description   = "Enable RBAC Authentication.  Should be left yo true"

}
variable "public_access" {
  type         = bool
  default      = false
  description  = "Is public access to storage account Allow og Deny?"
}
