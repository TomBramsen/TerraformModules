resource "random_password" "localAdmin" {
  length                 = 16
  special                = true
}

resource "azurerm_public_ip" "public_ip" {
  count = var.create_public_Ip ? 1 : 0
  name                   = "pip-${var.name}"
  resource_group_name    = var.rg_name
  location               = var.location
  allocation_method      = "Dynamic"
  sku                    = var.public_ip_sku
  sku_tier               = var.public_ip_sku_tier
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                   = "nic-${var.name}"
  location               = var.location
  resource_group_name    = var.rg_name

  ip_configuration {
    name                          = "ip-conf-${var.name}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = var.create_public_Ip  ? azurerm_public_ip.public_ip[0].id : null
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                   = var.name
  location               = var.location
  resource_group_name    = var.rg_name

  size                   = var.vm_size
  license_type           = "Windows_Client"
  admin_username         = var.userid
  admin_password         = ( var.userpsw != "" ? var.userpsw : random_password.localAdmin.result )
  network_interface_ids  = [ azurerm_network_interface.vm_network_interface.id ]

  enable_automatic_updates = var.vm_enable_automatic_updates

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
   
  ## See latest with Get-AzVmImageSku -Location 'northeurope' -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-11'
  source_image_reference {
    publisher            = "MicrosoftWindowsDesktop"
    offer                = "windows-11"
    sku                  = "win11-23h2-pro"
    version              = "latest"
  }
}
/*   Future improvement.   Initial script to run
resource "azurerm_virtual_machine_extension" "custom_script_parsec" {
  name                 = "parsec-post-deploy-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
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