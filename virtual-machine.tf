## LiveKit Server

resource "azurerm_network_interface" "vm-01-nic" {
  depends_on                        = [azurerm_resource_group.rg,
                                       azurerm_public_ip.pip-01
                                      ]

  name                              = "${var.azure-resource-name}-livekit-01-vm-nic"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name

  ip_configuration {
    name                            = "base-ip"
    subnet_id                       = azurerm_subnet.web-snet.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.pip-01.id
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_linux_virtual_machine" "vm-01" {
  depends_on                        = [
                                      azurerm_resource_group.rg,
                                      azurerm_network_interface.vm-01-nic
                                      ]

  name                              = "${var.azure-resource-name}-livekit-01-vm"
  computer_name                     = "${var.vm-01-hostname}-01"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.location
  size                              = var.vm-01-size
  admin_username                    = var.vm-admin
  network_interface_ids             = [azurerm_network_interface.vm-01-nic.id]
  custom_data                       = data.template_cloudinit_config.config.rendered

  admin_ssh_key {
    username                        = var.vm-admin
    public_key                      = file("./ssh-key/id_rsa-foundry.pub")
  }

  os_disk {
    name                            = "${var.azure-resource-name}-livekit-01-vm-osdisk"
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

## Production Server

resource "azurerm_network_interface" "vm-02-nic" {
  depends_on                        = [azurerm_resource_group.rg,
                                       azurerm_public_ip.pip-02
                                      ]

  name                              = "${var.azure-resource-name}-vtt-prd-01-nic"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name

  ip_configuration {
    name                            = "base-ip"
    subnet_id                       = azurerm_subnet.web-snet.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.pip-02.id
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_linux_virtual_machine" "vm-02" {
  depends_on                        = [
                                      azurerm_resource_group.rg,
                                      azurerm_network_interface.vm-02-nic
                                      ]

  name                              = "${var.azure-resource-name}-vtt-prd-01-vm"
  computer_name                     = "${var.vm-02-hostname}-01"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.location
  size                              = var.vm-02-size
  admin_username                    = var.vm-admin
  network_interface_ids             = [azurerm_network_interface.vm-02-nic.id]

  admin_ssh_key {
    username                        = var.vm-admin
    public_key                      = file("./ssh-key/id_rsa-foundry.pub")
  }

  os_disk {
    name                            = "${var.azure-resource-name}-vtt-prd-01-vm-osdisk"
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

resource "azurerm_managed_disk" "vm-02-disk" {
  depends_on                        = [azurerm_linux_virtual_machine.vm-02]

  name                              = "${var.azure-resource-name}-vtt-prd-01-vm-datadisk"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  storage_account_type              = "Standard_LRS"
  create_option                     = "Empty"
  disk_size_gb                      = var.vm-02-data-disk-size
  zone                              = 1

  tags                              = "${(local.tags)}"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-02-diskattach" {
  depends_on                        = [
                                      azurerm_managed_disk.vm-02-disk,
                                      azurerm_linux_virtual_machine.vm-02
                                      ]

  managed_disk_id                   = azurerm_managed_disk.vm-02-disk.id
  virtual_machine_id                = azurerm_linux_virtual_machine.vm-02.id
  lun                               = "10"
  caching                           = "ReadWrite"
}

## Test

resource "azurerm_network_interface" "vm-03-nic" {
  depends_on                        = [azurerm_resource_group.rg,
                                       azurerm_public_ip.pip-03
                                      ]

  name                              = "${var.azure-resource-name}-vtt-tst-01-nic"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name

  ip_configuration {
    name                            = "base-ip"
    subnet_id                       = azurerm_subnet.web-snet.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.pip-03.id
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_linux_virtual_machine" "vm-03" {
  depends_on                        = [
                                      azurerm_resource_group.rg,
                                      azurerm_network_interface.vm-03-nic
                                      ]

  name                              = "${var.azure-resource-name}-vtt-tst-01-vm"
  computer_name                     = "${var.vm-03-hostname}-01"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.location
  size                              = var.vm-03-size
  admin_username                    = var.vm-admin
  network_interface_ids             = [azurerm_network_interface.vm-03-nic.id]

  admin_ssh_key {
    username                        = var.vm-admin
    public_key                      = file("./ssh-key/id_rsa-foundry.pub")
  }

  os_disk {
    name                            = "${var.azure-resource-name}-vtt-tst-01-vm-osdisk"
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

resource "azurerm_managed_disk" "vm-03-disk" {
  depends_on                        = [azurerm_linux_virtual_machine.vm-03]

  name                              = "${var.azure-resource-name}-vtt-tst-01-vm-datadisk"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  storage_account_type              = "Standard_LRS"
  create_option                     = "Empty"
  disk_size_gb                      = var.vm-03-data-disk-size
  zone                              = 1

  tags                              = "${(local.tags)}"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-03-diskattach" {
  depends_on                        = [
                                      azurerm_managed_disk.vm-03-disk,
                                      azurerm_linux_virtual_machine.vm-03
                                      ]

  managed_disk_id                   = azurerm_managed_disk.vm-03-disk.id
  virtual_machine_id                = azurerm_linux_virtual_machine.vm-03.id
  lun                               = "10"
  caching                           = "ReadWrite"
}