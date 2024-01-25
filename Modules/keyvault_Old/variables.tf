
variable "resourcegroup" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
  default = "kv001"
}

variable "sku" {
  type = string
  default = "standard"
}

variable "kv_acces_object_id" {
  type = string
  default = "fcf6ff54-e483-4cdb-99a4-078c3c7edec7"   # Microsoft Azure App Service
}


variable "tags" {
  type = map(any)
  default = {
    environment = "Dev"
  }
}