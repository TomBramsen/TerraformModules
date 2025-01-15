
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

variable "serviceplan_name" {
   default      = "sp-name123123" // "afd-${lower(random_id.front_door_name.hex)}"
   type         = string
}
variable "os_type" {
  type = string
  default = "Linux"
}
variable "sku_name" {
  type = string
  default = "B1"
}

variable "app_name" {
   default      = "app-name123123" // "afd-${lower(random_id.front_door_name.hex)}"
   type         = string
}


variable "app_repo" {
//  default      = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
   default      =  "https://github.com/Azure-Samples/python-docs-hello-world"
   type         = string
}

variable "app_repo_branch" {
   default      = "master"
   type         = string
}


variable "docker_image" {
   type = string
   default = "patheard/hello-world"
}
variable "docker_image_tag" {
   type = string
   default = "latest"
}