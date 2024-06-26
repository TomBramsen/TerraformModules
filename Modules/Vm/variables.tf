# Variables for VM.   Only those values without a default value is needed


variable "rg_name" {
  type        = string
  description = "Name of resource group"
}

variable "location" {
  type        = string
}

variable "name" {
  type        = string
  description = "Remember to include environment as part of the name"
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to add vm into"
}

## --------------------------------
## Optional values
## --------------------------------
variable "userid" {
  type        = string
  default     = "azadmin"
  description = "The default user to log on with"
}

variable "userpsw" {
  type        = string
  default     = ""
  description = "User Password.  If left blank, random password will be used"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
}

variable "vm_enable_automatic_updates" {
  type        = bool
  default     = true
  description = "Should VM be automatic updated"
}

## Public IP - please do not configure! 
variable "create_public_Ip" {
  type        = bool
  default     = false
  description = "Please do not use public ip.  It will break security goals + complicate net flow troubleshooting"
}

variable "public_ip_sku" {
  type        = string
  default     = "Basic"
}
variable "public_ip_sku_tier" {
  type        = string
  default     = "Regional"
}

variable "storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "What kind of storage type should be used for OS Harddrive"
}

variable "tags" {
  type        = map(any)
  default     = {
    environment = "Dev"
  }
}