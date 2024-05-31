output "sql_id" {
  value            = azurerm_mssql_server.sql.id
}

output "database_ids" {
  value            =  [ for d in azurerm_mssql_database.db : d.id ]
}

output "AdminPSW" {
  value            = var.adminPSW == "" ? random_password.admin-password.result  : var.adminPSW
  sensitive        = true 
}

output "adminId" {
  value            = var.adminId
}

output "endpoints_ids" {
  value            =  azurerm_private_endpoint.MSSQLPrivateEndpoint[*].id
  description      = "ID for the private endpoints, if created"
}

output "endpoints_ips" {
  value            =  data.azurerm_private_endpoint_connection.endpoint_IPs[*].private_service_connection.0.private_ip_address
  description      = "Private IP for the private endpoints, if created"
}