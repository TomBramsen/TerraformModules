
##
##     Windows Jumphost
##

resource "azurerm_resource_group" "winJumpRg" {
  name                   = lower("${var.win_jump_config.rg_name}-${local.name_postfix}")
  location               = var.location
  tags                   = var.tags
 }

resource "random_password" "localAdmin" {
  length                 = 16
  special                = false
}

resource "azurerm_network_interface" "winJump" {
  count               = 1
  name                = "nic-jump${count.index}"
  location            = azurerm_resource_group.winJumpRg.location
  resource_group_name = azurerm_resource_group.winJumpRg.name

  ip_configuration {
    name                          = "nic-ipconf"
    subnet_id                     = azurerm_subnet.conectivitySubnet["jumphost_win"].id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "winJump" {
  count               = 1
  name                = lower("${var.win_jump_config.name}${count.index}-${local.name_postfix_short}") 
  location            = azurerm_resource_group.winJumpRg.location
  resource_group_name = azurerm_resource_group.winJumpRg.name
  tags                = var.tagsVM

  size                  = var.win_jump_config.size
  license_type          = "Windows_Client"
  admin_username        = "azadmin"
  admin_password        = random_password.localAdmin.result
  network_interface_ids = [azurerm_network_interface.winJump[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }
}


##
##     Windows vm for schedules tasks
##

resource "azurerm_resource_group" "winJumpSch" {
  name                   = lower("${var.win_sch_config.rg_name}-${local.name_postfix}")
  location               = var.location
  tags                   = var.tags
 }

resource "random_password" "localAdminSch" {
  length                 = 16
  special                = false
}

# Save  password in keyvault
resource "azurerm_key_vault_secret" "sch_vm_azadmin" {
  name         = "schvmAdmin"
  content_type = "Scheduled VM host login."
  key_vault_id = azurerm_key_vault.keyvault.id
  value        = "azadmin"
}

resource "azurerm_key_vault_secret" "sch_vm_psw" {
  name         = "schvmPass"
  content_type = "Scheduled VM host login. "
  key_vault_id = azurerm_key_vault.keyvault.id
  value        = random_password.localAdminSch.result
}

resource "azurerm_network_interface" "winsch" {
  name                = lower("nic-${var.win_sch_config.name}")
  location            = var.location
  resource_group_name = azurerm_resource_group.winJumpSch.name

  ip_configuration {
    name                          = "nic-ipconf-${var.win_sch_config.name}"
    subnet_id                     = azurerm_subnet.conectivitySubnet["jumphost_win"].id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "winJumpSch" {
  name                = lower("${var.win_sch_config.name}-${local.name_postfix_short}") 
  location            = azurerm_resource_group.winJumpSch.location
  resource_group_name = azurerm_resource_group.winJumpSch.name
  tags                = var.tagsVM

  size                  = var.win_sch_config.size
  license_type          = "Windows_Client"
  admin_username        = "azadmin"
  admin_password        = random_password.localAdminSch.result
  network_interface_ids = [azurerm_network_interface.winsch.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  name                       = "AADLogin"
  virtual_machine_id         = azurerm_windows_virtual_machine.winJumpSch.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0" 
  #automatic_upgrade_enabled  = true
  #auto_upgrade_minor_version = true
}

resource "azurerm_role_assignment" "role_vm_login" {
 scope                   = azurerm_windows_virtual_machine.winJumpSch.id
 role_definition_name    = "Virtual Machine Administrator Login" 
 principal_id            = "f728759d-8331-430a-b28a-038248c2f28f" # Trifork reader
}