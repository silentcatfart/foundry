data "cloudinit_config" "livekit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/livekit.yaml.tftpl", {
      livekit_api_key    = var.livekit_api_key
      livekit_api_secret = var.livekit_api_secret
    })
  }
}

resource "azurerm_public_ip" "vm" {
  for_each = var.vms

  name                = "${var.name_prefix}-${each.key}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "vm" {
  for_each = var.vms

  name                = "${var.name_prefix}-${each.key}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "base-ip"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                  = "${var.name_prefix}-${each.key}-vm"
  computer_name         = each.value.hostname
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = each.value.size
  priority              = "Spot"
  eviction_policy       = "Delete"
  max_bid_price         = -1
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]
  custom_data           = each.value.livekit ? data.cloudinit_config.livekit.rendered : null
  tags                  = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_public_key_path)
  }

  os_disk {
    name                 = "${var.name_prefix}-${each.key}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data" {
  for_each = var.vms

  name                 = "${var.name_prefix}-${each.key}-vm-datadisk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk_size
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = var.vms

  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = 0
  caching            = "ReadWrite"
}
