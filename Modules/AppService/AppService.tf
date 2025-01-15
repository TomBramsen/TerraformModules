# Generate a random integer to create a globally unique name
/*
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
*/



# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = var.serviceplan_name
  location            = var.location
  resource_group_name = var.rg_name
  os_type             = var.os_type
  sku_name            = var.sku_name
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = var.app_name
  location              = var.location
  resource_group_name   = var.rg_name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  depends_on            = [azurerm_service_plan.appserviceplan]
  https_only            = true

site_config {
    always_on      = "true"
  }
}


/*
#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.webapp.id

  # repo_url = "https://github.com/azureappserviceoss/wordpress-azure"
   # branch = "master"
      repo_url = "https://github.com/Azure-Samples/python-docs-hello-world"
  branch   = "master"

  use_manual_integration = false
  use_mercurial      = false
}
*/
