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
  name                         = "DB"
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

resource "azurerm_private_endpoint" "MSSQLPrivateEndpoint" {
  name                = "endpoint-${azurerm_mssql_server.sql.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnetId

  private_service_connection {
    name                           = "sc-${azurerm_mssql_server.sql.name}"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
/*  ip_configuration {
    name                           = "ip-${var.MSSQLLEndpointName}-${local.name_postfix}"
    private_ip_address             = var.MSSQLLEndpointIIP
    subresource_name               = "sqlServer" 
  }
  */
}

# Find the IP Address associated with the private endpoint created above
data "azurerm_private_endpoint_connection" "mssql_ple_connection" {
  name                             = azurerm_private_endpoint.MSSQLPrivateEndpoint.name
  resource_group_name              = var.rg_name
  depends_on                       = [ azurerm_private_endpoint.MSSQLPrivateEndpoint ]
}
/*
# Create DNS Record for storylab storage in private dns zone
resource "azurerm_private_dns_a_record" "storylab_mssql_dnsrecord" {
  provider                         = azurerm.connectivity
  name                             = "${var.storylab_privatelink_dnskey}-${var.environment}"
  zone_name                        = "privatelink.database.windows.net"
  resource_group_name              = "rg-dns-connectivity-neu"
  ttl                              = 300
  records                          = [ data.azurerm_private_endpoint_connection.mssql_ple_connection.private_service_connection.0.private_ip_address ]
}
*/