resource "azurerm_resource_group" "rg-postgres" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}

# azurerm_postgresql_server will be retired march 2025, so using flexible server instead
resource "azurerm_postgresql_flexible_server" "postgresServer" {
  name                         = var.serverName
  location                     = var.location
  resource_group_name          = var.rg_name

  administrator_login          = var.adminUser
  administrator_password       = var.adminPsw
  sku_name                     = var.sku
  version                      = var.dbversion
  storage_mb                   = var.storage_mb
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup
  zone                         = var.zone
  
  maintenance_window {
    day_of_week                = 0 // Sunday
    start_hour                 = 23 
    start_minute               = 0
  }
  depends_on = [ azurerm_resource_group.rg-postgres ]
}

resource "azurerm_postgresql_flexible_server_database" "postgresDB" {
  name                        = var.dbName
  server_id                   = azurerm_postgresql_flexible_server.postgresServer.id
  collation                   = "en_US.utf8"
  charset                     = "utf8"
  
  /*
  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
  */
  depends_on = [ azurerm_postgresql_flexible_server.postgresServer ]
}

/*    NOT supported yet
resource "azurerm_private_endpoint" "postgresEndpoint" {
  name                = "${var.postgres.private_endpoint_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.postgres.rg_name
  subnet_id           = azurerm_subnet.mosaic-gallery-subnet.id

  private_service_connection {
    name                           = "sc-${var.postgres.private_endpoint_name}-${var.environment}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgresServer.id
    subresource_names              = [ "postgresqlServer ???" ]
    is_manual_connection           = false
  }
}
*/