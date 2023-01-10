resource "azurerm_network_interface" "core-vpn-01-vm-nic" {
  depends_on                        = [azurerm_resource_group.core-vm-rg]

  name                              = "${var.azure-resource-name}-core-vpn-01-vm-nic"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.core-vm-rg.name
  enable_ip_forwarding              = true

  ip_configuration {
    name                            = "base-ip"
    subnet_id                       = var.vpn-snet
    private_ip_address_allocation   = "Dynamic"
  }

  tags                              = "${(local.tags)}"
}

resource "azurerm_linux_virtual_machine" "core-vpn-01-vm" {
  depends_on                        = [
                                      azurerm_resource_group.core-vm-rg,
                                      azurerm_network_interface.core-vpn-01-vm-nic
                                      ]

  name                              = "${var.azure-resource-name}-core-vpn-01-vm"
  computer_name                     = "${var.server-hostname}11-01"
  resource_group_name               = azurerm_resource_group.core-vm-rg.name
  location                          = var.location
  size                              = var.vm-size
  admin_username                    = var.vm-admin

  network_interface_ids             = [azurerm_network_interface.core-vpn-01-vm-nic.id]

  identity {
    type                            = "UserAssigned"
    identity_ids                    = ["${var.vm-managed-identity}"]
  }

  admin_ssh_key {
    username                        = var.vm-admin
    public_key                      = file("./ssh-key/id_rsa.pub")
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

  tags                              = "${merge(local.tags, local.reservation)}"
}

resource "azurerm_virtual_machine_extension" "core-vpn-01-vm-mmagent-ext" {
  depends_on                        = [azurerm_linux_virtual_machine.core-vpn-01-vm]

  name                              = "mmagent"
  virtual_machine_id                = azurerm_linux_virtual_machine.core-vpn-01-vm.id
  publisher                         = "Microsoft.EnterpriseCloud.Monitoring"
  type                              = "OmsAgentForLinux"
  type_handler_version              = "1.0"
  auto_upgrade_minor_version        = "true"

  settings                          = <<SETTINGS
    {
      "workspaceId": "${var.mmagent-workspaceid}"
    }
  SETTINGS

   protected_settings               = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${var.mmagent-workspacekey}"
   }
  PROTECTED_SETTINGS
}

resource "azurerm_backup_protected_vm" "core-vpn-01-vm-rsvvm" {
  depends_on                        = [
                                      azurerm_backup_policy_vm.core-rsv-policy,
                                      azurerm_linux_virtual_machine.core-vpn-01-vm
                                      ]

  resource_group_name               = azurerm_resource_group.core-vm-rg.name
  recovery_vault_name               = azurerm_recovery_services_vault.core-rsv.name
  source_vm_id                      = azurerm_linux_virtual_machine.core-vpn-01-vm.id
  backup_policy_id                  = azurerm_backup_policy_vm.core-rsv-policy.id
}

resource "logicmonitor_device" "core-vpn-01-vm-lm-device" {
  depends_on                        = [
                                      azurerm_linux_virtual_machine.core-vpn-01-vm
                                      ]

  name                              = azurerm_linux_virtual_machine.core-vpn-01-vm.computer_name
  display_name                      = azurerm_linux_virtual_machine.core-vpn-01-vm.name
  description                       = azurerm_linux_virtual_machine.core-vpn-01-vm.name
  preferred_collector_id            = 117
  host_group_ids                    = "1794"

  custom_properties = [
        {
            name                    = "snmp.community"
            value                   = "Motor-Owe-Notebook-Spell-3"
        },
        {
            name                    = "snmp.version"
            value                   = "v2c"
        },
        {
            name                    = "system.categories"
            value                   = "snmpTCPUDP,Netsnmp,snmpHR,snmp"
        }

    ]
  lifecycle {
    ignore_changes                  = all
  }
}