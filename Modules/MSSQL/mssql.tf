module "Global_Constants" {
   source = "../Global_Constants"
}

resource "azurerm_resource_group" "rg-sql" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}


##
## MSSQL
##

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


resource "azurerm_mssql_database" "db" {
  for_each = toset(var.databases)
  name                         = each.value
  server_id                    = azurerm_mssql_server.sql.id
  max_size_gb                  = 50     # https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#arguments-1
  sku_name                     = "S0"
  zone_redundant               = false
  geo_backup_enabled           = false

  short_term_retention_policy {
    retention_days             = 7
    backup_interval_in_hours   = 24    # 12-24 allowed
  }
  
  long_term_retention_policy {
    monthly_retention          = "P3M"  # Past 6 months
    week_of_year               = 1      # Week of year for yearly backup
    weekly_retention           = "P4W"  # Past 8 weeks
    yearly_retention           = "PT0S" # none
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
