# https://medium.com/@antoine.loizeau/terraform-module-azure-diagnostic-settings-96b4bcd3737f

data "azurerm_monitor_diagnostic_categories" "categories" {
  count                      = length(var.targets_resource_id)
  resource_id                = var.targets_resource_id[count.index]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count                      = length(var.targets_resource_id)
  name                       = split("/", var.log_analytics_workspace_id)[length(split("/", var.log_analytics_workspace_id)) - 1]
  target_resource_id         = data.azurerm_monitor_diagnostic_categories.categories[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  