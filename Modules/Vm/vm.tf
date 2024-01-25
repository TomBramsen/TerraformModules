resource "random_password" "localAdmin" {
  length                 = 10
  special                = false
}

resource "azurerm_public_ip" "public_ip" {
  count = var.create_public_Ip ? 1 : 0
  name                = "pip-${var.name}"
  resource_group_name = var.resourcegroup
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "network_interface" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "ip-conf-${var.name}"
    subnet_id                     = var.netid
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = var.create_public_Ip  ? azurerm_public_ip.public_ip[0].id : null
  }
  lifecycle {
    create_before_destroy = true
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
  network_interface_ids = [ azurerm_network_interface.network_interface.id ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
   
  ## See latest with Get-AzVmImageSku -Location 'northeurope' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-11'
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }
}
/*
resource "azurerm_virtual_machine_extension" "custom_script_parsec" {
  name                 = "parsec-post-deploy-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
 

       settings = jsonencode({ "commandToExecute" = "powershell -command \" System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf-script.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File test.ps1" })
  protected_settings = jsonencode({ "managedIdentity" = {} })
  }

*/
/*
 provisioner "file" {
    source      = "test.ps1"
    destination = "C:/azure/test.ps1"
  }
  */