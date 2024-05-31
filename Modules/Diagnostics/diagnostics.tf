# https://medium.com/@antoine.loizeau/terraform-module-azure-diagnostic-settings-96b4bcd3737f


# Options to enable / disable log data
# Options to provide your own log settings instead of choosing everything
# - Please note, if you remove settings already set, it will not be removed.
#   Instead, remove diagnostic settings in portal, and run terraform again to get updated values!

data "azurerm_monitor_diagnostic_categories" "categories" {
  count                      = length(var.targets_resource_id)
  resource_id                = var.targets_resource_id[count.index]
}

locals {
   MetricsCheck  = length(var.specific_metrics) == 0 ?  data.azurerm_monitor_diagnostic_categories.categories[*].metrics :  var.specific_metrics
   LogCheck      = length(var.specific_logs) == 0 ?  data.azurerm_monitor_diagnostic_categories.categories[*].log_category_types :  var.specific_logs
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count                      = length(var.targets_resource_id)
  name                       = split("/", var.log_analytics_workspace_id)[length(split("/", var.log_analytics_workspace_id)) - 1]
  target_resource_id         = data.azurerm_monitor_diagnostic_categories.categories[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[count.index].metrics 
    content {
      category = metric.value
      enabled  = contains(local.MetricsCheck[count.index], metric.value) ? true : false 
    }
  }

 dynamic "enabled_log" {
  for_each = var.enable_logs == false ? [] :  local.LogCheck[count.index] 
    content {
      category = enabled_log.value
    }
  }
  
}
