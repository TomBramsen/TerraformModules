
/*
output "web_apps_outbound_ip_addresses" {
  description = "The outbound IP addresses of the linux Function Apps."
  value       = { for app in azurerm_linux_web_app.webapp : app.name => app.outbound_ip_addresses }
}

output "web_apps_default_hostnames" {
  description = "The default hostnames of the linux Function Apps."
  value       = { for app in azurerm_linux_web_app.webapp : app.name => app.default_hostname }
}

*/
output "web_apps_default_hostnames" {
  description = "The default hostnames of the linux Function Apps."
  value       = azurerm_linux_web_app.webapp.default_hostname 
}