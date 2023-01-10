resource "azurerm_network_interface" "web01-vm-nic" {
  depends_on                        		            = [
                                                    azurerm_resource_group.rg,
                                                    azurerm_subnet.web-snet
                                                    ]

  name                              		            = "${var.resource-prefix}-web01-nic"
  location                          		            = var.location
  resource_group_name               		            = azurerm_resource_group.rg.name

  ip_configuration {
    name                            		            = "base-ip"
    subnet_id                       		            = azurerm_subnet.web-snet.id
    private_ip_address_allocation   		            = "Static"
    private_ip_address                              = var.web-vm-baseip
    primary                                         = "true"
  }

  ip_configuration {
    name                            		            = "${var.resource-prefix}-web01-vip01"
    subnet_id                       		            = azurerm_subnet.web-snet.id
    private_ip_address_allocation   		            = "Static"
    private_ip_address                              = var.web-vm-vip01
    primary                                         = "false"
  }

  tags = {
    managed-by                                      = "terraform"
    project                                         = var.project-tag
  }
}

resource "random_password" "vm-kv-password" {
  depends_on                                        = [azurerm_key_vault.kv]

  length                                            = 16
  special                                           = true
}

resource "azurerm_key_vault_secret" "vm-kv-gatewayadmin-secret" {
  depends_on                                        = [
                                                    azurerm_key_vault_access_policy.kv-access-policy-tfcloud,
                                                    random_password.vm-kv-password
                                                    ]

  name                                              = "${var.resource-prefix}-web01-vm-gatewayadmin-secret"
  value                                             = random_password.vm-kv-password.result
  key_vault_id                                      = azurerm_key_vault.kv.id
}

resource "azurerm_windows_virtual_machine" "web01-vm" {
  depends_on                                        = [
                                                    azurerm_resource_group.rg,
                                                    azurerm_network_interface.web01-vm-nic,
                                                    azurerm_key_vault_secret.vm-kv-gatewayadmin-secret
                                                    ]

  name                                              = "${var.resource-prefix}-web01-vm"
  computer_name                                     = "${var.hostname}web01"
  location                                          = var.location
  resource_group_name                               = azurerm_resource_group.rg.name
  size                                              = var.vm-size
  admin_username                                    = var.vm-admin
  admin_password                                    = azurerm_key_vault_secret.vm-kv-gatewayadmin-secret.value
  network_interface_ids                             = [azurerm_network_interface.web01-vm-nic.id]
  timezone                                          = var.timezone

  os_disk {
    name                                            = "${var.resource-prefix}-web01-osdisk"
    caching                                         = "ReadWrite"
    storage_account_type                            = "Standard_LRS"
  }

  source_image_reference {
    publisher                                       = "MicrosoftWindowsServer"
    offer                                           = "WindowsServer"
    sku                                             = "2022-datacenter-azure-edition"
    version                                         = "latest"
  }

  tags = {
    managed-by                                      = "terraform"
    project                                         = var.project-tag
  }
}

resource "azurerm_managed_disk" "web01-data" {
  depends_on                                        = [
                                                    azurerm_resource_group.rg,
                                                    ]

  name                                              = "${var.resource-prefix}-web01-data"
  location                                          = var.location
  resource_group_name                               = azurerm_resource_group.rg.name
  storage_account_type                              = "Standard_LRS"
  create_option                                     = "Empty"
  disk_size_gb                                      = var.data-disk-size

  tags = {
    managed-by                                      = "terraform"
    project                                         = var.project-tag
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "web01-dataattach" {
  depends_on                                        = [
                                                    azurerm_managed_disk.web01-data,
                                                    azurerm_windows_virtual_machine.web01-vm
                                                    ]

  managed_disk_id                                   = azurerm_managed_disk.web01-data.id
  virtual_machine_id                                = azurerm_windows_virtual_machine.web01-vm.id
  lun                                               = "10"
  caching                                           = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "ansible-winrm" {
    name                                            = "ansible-winrm"
    virtual_machine_id                              = azurerm_windows_virtual_machine.web01-vm.id
    publisher                                       = "Microsoft.Compute"
    type                                            = "CustomScriptExtension"
    type_handler_version                            = "1.8"
    settings                                        = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"],
            "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
        }
    SETTINGS
    }