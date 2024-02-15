module "Global_Constants" {
   source = "../Global_Constants"
}

resource "azurerm_resource_group" "rg-sql" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          =  var.adminId
  administrator_login_password = "Kodeord1234567" #random_password.admin-password.result    # Password created and stored in Keyvault
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_firewall_rule" "sql-whitelist" {
  count            = var.public_access ? 0 : length(module.Global_Constants.IP_Whitelist)
  name             = "Location-${count.index}"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = cidrhost(module.Global_Constants.IP_Whitelist[count.index],0)
  end_ip_address   = cidrhost(module.Global_Constants.IP_Whitelist[count.index],-1)
}

resource "azurerm_mssql_database" "db" {
  count = length( var.databases )
  name                         = var.databases[count.index].name
  server_id                    = azurerm_mssql_server.sql.id
  max_size_gb                  = var.databases[count.index].size   
  sku_name                     = var.databases[count.index].sku_name
  zone_redundant               = var.databases[count.index].zone_redundant
  geo_backup_enabled           = var.databases[count.index].geo_backup_enabled

  dynamic "short_term_retention_policy" {
    for_each = var.databases[count.index].retention_enabled == true ? [1] : [] 
    content {
      retention_days           = var.databases[count.index].retention_days
      backup_interval_in_hours = var.databases[count.index].backup_interval_in_hours
    }
  }
  
  dynamic "long_term_retention_policy" {
    for_each = var.databases[count.index].retention_enabled == true ? [1] : [] 
    content {
      monthly_retention        = var.databases[count.index].monthly_retention
      week_of_year             = var.databases[count.index].week_of_year
      weekly_retention         = var.databases[count.index].weekly_retention
      yearly_retention         = var.databases[count.index].yearly_retention
    }
  }
}


##
## Private Endpoint 
##
locals {
  create_private_endpoint = var.privateEndpointSubnet == 0 ? false : true 
}

resource "azurerm_private_endpoint" "MSSQLPrivateEndpoint" {
  count               = local.create_private_endpoint  ? 0  : 1
  name                = "endpoint-${azurerm_mssql_server.sql.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.privateEndpointSubnet

  private_service_connection {
    name                           = "sc-${azurerm_mssql_server.sql.name}"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

output "sql_id" {
  value  = azurerm_mssql_server.sql.id
}

output "database_ids" {
  value =  [ for d in azurerm_mssql_database.db : d.id ]
}
