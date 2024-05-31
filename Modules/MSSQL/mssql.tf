## Creates MS SQL Server

/* Usage example : 
module "sql" {
  source                = "git::https://github.com/LEGO-House/terraform-modules.git//Terraform/Modules/SQL"
  rg_name               = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  tags                  = var.tags
  name                  = "SQLDatabaseTest"
  databases             = [ { "name" = "db1" } ]
}

Many options exists in the databases object, like replication
Specify subnet id to privateEndpointSubnet, if private endpoint is needed
*/

## Global LH Terraform modules.  Import Global Constants
module "Global" {
 source = "../Global"
}

resource "random_password" "admin-password" {
  length                 = 16
  special                = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = var.SQLversion
  administrator_login          = var.adminId
  administrator_login_password = var.adminPSW == "" ? random_password.admin-password.result  : var.adminPSW
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_firewall_rule" "sql-whitelist" {
  count            = length(module.Global.IP_Whitelist)
  name             = "Location-${count.index}"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = cidrhost(module.Global.IP_Whitelist[count.index],0)
  end_ip_address   = cidrhost(module.Global.IP_Whitelist[count.index],-1)
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

## Need this as terraform plan needs to estimate count, and this workarount manages that

resource "azurerm_private_endpoint" "MSSQLPrivateEndpoint" {
  count               =  length(var.privateEndpointSubnet)
  name                = "endpoint-sql-${count.index}-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.privateEndpointSubnet[count.index]

  private_service_connection {
    name                           = "sc-${count.index}-${azurerm_mssql_server.sql.name}"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

# Find the IP Address associated with the private endpoint created above
data "azurerm_private_endpoint_connection" "endpoint_IPs" {
  count               = length(var.privateEndpointSubnet)
  name                = "endpoint-sql-${count.index}-${var.name}"
  resource_group_name =  var.rg_name
  depends_on          = [ azurerm_private_endpoint.MSSQLPrivateEndpoint ]
}


module "sql_diag" {
  count                      = var.enableAnalyticsMetrics ? 1 : 0 
  source                     = "github.com/TomBramsen/TerraformModules/Modules/Diagnostics"
  log_analytics_workspace_id = var.log_analytics_id
  targets_resource_id        = [ for d in azurerm_mssql_database.db : d.id ]
  enable_logs                = var.enableAnalyticsLogs
}