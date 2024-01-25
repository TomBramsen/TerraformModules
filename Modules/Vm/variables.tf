
variable "resourcegroup" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
  default = "vm001"
}

variable "netid" {
  type = string
}

variable "vm_size" {
  type = string
  default = "Standard_B2s"
}

variable "create_public_Ip" {
  type = bool
  default = true
}

variable "userid" {
  type = string
  default = "azadmin"
  description = "The default user to log on with"
}

variable "userpsw" {
  type = string
  default = ""
  description = "User Password.  If left blank, random password will be used"
}

variable "storage_account_type" {
  type = string
  default = "Standard_LRS"
}

variable "tags" {
  type = map(any)
  default = {
    environment = "Dev"
  }
}