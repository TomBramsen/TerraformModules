
##
##     Windows VM
##


resource "random_password" "localAdmin" {
  length                 = 10
  special                = false
}

resource "azurerm_network_interface" "vmnet" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "${var.name}-ipconf"
    subnet_id                     = var.netid
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "vm" {
   name                = var.name
  location            = var.location
  resource_group_name = var.resourcegroup

  size                  = var.vm_size
  license_type          = "Windows_Client"
  admin_username        = "azadmin"
  admin_password        = "Kodeord123456" # random_password.localAdmin.result
  network_interface_ids = azurerm_network_interface.vmnet.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }
}