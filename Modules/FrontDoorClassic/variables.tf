
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

variable "name" {
   default      = "afd-frontdoor" // "afd-${lower(random_id.front_door_name.hex)}"
   type         = string
}

variable "endpoint_name" {
   default      = "afd-Endpoint"
   type         = string
}

variable "load_balancing_settings_name" {
   default      = "afd-loadBalancingSettings"
   type         = string
}

variable "health_probe_settings_name" {
   default      = "afd-healthProbeSettings"
   type         = string
}

variable "front_door_routing_rule_name" {
   default      = "afd-routingRule"
   type         = string
}

variable "front_door_backend_pool_name" {
   default      = "afd-backendPool"
   type         = string
}

variable "backend_address" {
  default = "tv2oj.dk"
}