output "vm_id" {
  value = azurerm_windows_virtual_machine.vm.id
}

output "private_ip_address" {
  value = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "admin_password" {
  value = var.userpsw != "" ? var.userpsw : random_password.localAdmin.result 
}
