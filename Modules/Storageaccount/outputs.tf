output "storageaccount_id" {
  value  = azurerm_storage_account.storageaccount.id
}

output "container_ids" {
  value =  [ for c in azurerm_storage_container.containers : c.id ]
}
/*
output "endpoints_ids" {
  value            =  azurerm_private_endpoint.StorageAccountEndpoint[*].id
  description      = "ID for the private endpoints, if created"
}

output "endpoints_ips" {
  value            =  data.azurerm_private_endpoint_connection.endpoint_IPs[*].private_service_connection.0.private_ip_address
  description      = "Private IP for the private endpoints, if created"
}
*/
