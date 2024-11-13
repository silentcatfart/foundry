resource "azurerm_network_interface" "vm-01-nic" {
  depends_on                        = [azurerm_resource_group.rg,
                                       azurerm_public_ip.pip
                                      ]

  name                              = "${var.azure-resource-name}-vm-01-nic"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  enable_ip_forwarding              = true

  ip_configuration {
    name                            = "base-ip"
    subnet_id                       = azurerm_subnet.web-snet.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.pip.id
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_linux_virtual_machine" "vm-01" {
  depends_on                        = [
                                      azurerm_resource_group.rg,
                                      azurerm_network_interface.vm-01-nic,
                                      azurerm_public_ip.pip
                                      ]

  name                              = "${var.azure-resource-name}-01-vm"
  computer_name                     = "${var.server-hostname}-01"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.location
  size                              = var.vm-size
  admin_username                    = var.vm-admin

  network_interface_ids             = [azurerm_network_interface.vm-01-nic.id]

  identity {
    type                            = "UserAssigned"
    identity_ids                    = [azurerm_user_assigned_identity.managed-id.id]
  }

  admin_ssh_key {
    username                        = var.vm-admin
    public_key                      = file("./ssh-key/id_rsa-foundry.pub")
  }

  os_disk {
    caching                         = "ReadWrite"
    storage_account_type            = "Standard_LRS"
  }

  source_image_reference {
    publisher                       = "Canonical"
    offer                           = "0001-com-ubuntu-server-focal"
    sku                             = "20_04-lts-gen2"
    version                         = "latest"
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_managed_disk" "vm-01-disk" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-vm-01-disk"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  storage_account_type              = "Standard_LRS"
  create_option                     = "Empty"
  disk_size_gb                      = var.data-disk-size
  zone                              = 1

  tags                              = "${(local.tags)}"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-01-diskattach" {
  depends_on                        = [
                                      azurerm_managed_disk.vm-01-disk,
                                      azurerm_linux_virtual_machine.vm-01
                                      ]

  managed_disk_id                   = azurerm_managed_disk.vm-01-disk.id
  virtual_machine_id                = azurerm_linux_virtual_machine.vm-01.id
  lun                               = "10"
  caching                           = "ReadWrite"
}

resource "azurerm_backup_protected_vm" "vm-01-rsvvm" {
  depends_on                        = [
                                      azurerm_backup_policy_vm.rsv-policy,
                                      azurerm_linux_virtual_machine.vm-01
                                      ]

  resource_group_name               = azurerm_resource_group.rg.name
  recovery_vault_name               = azurerm_recovery_services_vault.rsv.name
  source_vm_id                      = azurerm_linux_virtual_machine.vm-01.id
  backup_policy_id                  = azurerm_backup_policy_vm.rsv-policy.id
}
