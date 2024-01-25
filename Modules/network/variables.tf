
variable "resourcegroup" {
  type = string
}

variable "location" {
  type = string
   default = "westeurope"
}

variable "name" {
  type = string
  default = "net-001"
}

variable "address_space" {
  type = list(string)
  default = ["10.1.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name         = string  
    ip_range     = list(string)
   }))
  default = [
    {  
      name       = "subnet1"
      ip_range   = ["10.1.1.0/24"]
     }
  ]
}



variable "tags" {
  type = map(any)
  default = {
    environment = "Dev"
  }
}
