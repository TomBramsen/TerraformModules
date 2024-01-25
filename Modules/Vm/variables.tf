
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

variable "tags" {
  type = map(any)
  default = {
    environment = "Dev"
  }
}