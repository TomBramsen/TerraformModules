
##
##     Windows Jumphost
##

resource "azurerm_resource_group" "rg_vm" {
  count                   = var.create_rg_group ? 1  : 0
  name                    = var.rg_name
  location                = var.location
}


resource "random_password" "localAdmin" {
  length                 = 10
  special                = true
}

resource "azurerm_network_interface" "netinterface" {
  name                = "nic-${var.vm_size}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ipconf-${var.vm_name}"
    subnet_id                     = var.netid
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_resource_group.rg_vm ]
}
resource "azurerm_windows_virtual_machine" "VM" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.rg_name

  size                  = var.vm_size
  license_type          = "Windows_Client"
  admin_username        = var.admin_user
  admin_password        = random_password.localAdmin.result
  network_interface_ids = [ azurerm_network_interface.netinterface.id ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }
}
/*
resource "azurerm_virtual_machine_extension" "custom_script_parsec" {
  name                 = "parsec-post-deploy-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.winJump.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
 

       settings = jsonencode({ "commandToExecute" = "powershell -command \" System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf-script.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File test.ps1" })
  protected_settings = jsonencode({ "managedIdentity" = {} })
  }


 provisioner "file" {
    source      = "test.ps1"
    destination = "C:/azure/test.ps1"
  }

  */