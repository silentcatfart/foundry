# NSGs
resource "azurerm_network_security_group" "web-snet-nsg" {
  depends_on                        		         = [azurerm_resource_group.rg]

  name                                           = "${var.resource-prefix}-web-snet-nsg"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.rg.name

  tags = {
    managed-by                                   = "terraform"
    project                                      = var.project-tag
  }
}

resource "azurerm_network_security_group" "bastion-snet-nsg" {
  depends_on                        		         = [azurerm_resource_group.rg]

  name                                           = "${var.resource-prefix}-bastion-snet-nsg"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.rg.name

  tags = {
    managed-by                                   = "terraform"
    project                                      = var.project-tag
  }
}

# Rules
resource "azurerm_network_security_rule" "web-snet-nsg-winrm-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-WinRM-Inbound"
  description                                    = "Needed for Ansible"
  priority                                       = 100
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_ranges                        = ["5985","5986"]
  source_address_prefixes                        = ["10.85.4.176/28"]
  destination_address_prefix                     = "${var.snet-web-address}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-rdp-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-RDP-Inbound"
  description                                    = "Needed for remote administration"
  priority                                       = 120
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_range                         = "3389"
  source_address_prefixes                        = ["10.85.4.176/28","${var.snet-bastion-address}"]
  destination_address_prefix                     = "${var.snet-web-address}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-lm-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-LogicMonitor-Inbound"
  description                                    = "Needed for monitoring"
  priority                                       = 130
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "*"
  source_address_prefixes                        = ["10.71.4.132/32","10.86.4.132/32","10.35.4.132/32","10.42.4.132/32"]
  destination_address_prefix                     = "${var.snet-web-address}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-web-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-WebServer-Inbound"
  description                                    = "For testing IIS"
  priority                                       = 140
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_ranges                        = ["80","443"]
  source_address_prefixes                        = ["10.85.4.176/28"]
  destination_address_prefix                     = "${var.snet-web-address}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-withvlan-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-Within-VLAN"
  description                                    = "Allow server to server communication within same subnet"
  priority                                       = 150
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "*"
  source_address_prefix                          = "${var.snet-web-address}"
  destination_address_prefix                     = "${var.snet-web-address}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-denyall-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Deny-All-Inbound"
  description                                    = "Supercede default deny"
  priority                                       = 4096
  direction                                      = "Inbound"
  access                                         = "Deny"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "*"
  source_address_prefix                          = "*"
  destination_address_prefix                     = "*"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-browsing-out" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-Web-Browsing-Outbound"
  description                                    = "Allow outbound web access to the Internet"
  priority                                       = 100
  direction                                      = "Outbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_ranges                        = ["80","443"]
  source_address_prefix                          = "${var.snet-web-address}"
  destination_address_prefix                     = "Internet"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-denyall-out" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Deny-All-Internet-Outbound"
  description                                    = "Supercede default deny outbound to the Internet"
  priority                                       = 4096
  direction                                      = "Outbound"
  access                                         = "Deny"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "*"
  source_address_prefix                          = "${var.snet-web-address}"
  destination_address_prefix                     = "Internet"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

# Bastion NSG rules - required for operation - https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg

resource "azurerm_network_security_rule" "bastion-nsg-allow-https-in" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-HTTPS-In"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 120
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "TCP"
  source_port_range                              = "*"
  destination_port_range                         = "443"
  source_address_prefix                          = "Internet"
  destination_address_prefix                     = "*"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-gwmanager-in" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Gateway-Manager-In"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 130
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "TCP"
  source_port_range                              = "*"
  destination_port_range                         = "443"
  source_address_prefix                          = "GatewayManager"
  destination_address_prefix                     = "*"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-azurelb-in" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Azure-Load-Balancer-In"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 140
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "TCP"
  source_port_range                              = "*"
  destination_port_range                         = "443"
  source_address_prefix                          = "AzureLoadBalancer"
  destination_address_prefix                     = "*"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-bastionhost-in" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Bastion-Host-Communication-In"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 150
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_ranges                         = ["8080","5701"]
  source_address_prefix                          = "VirtualNetwork"
  destination_address_prefix                     = "VirtualNetwork"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-sshrdp-out" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-SSH-RDP-Out"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 100
  direction                                      = "Outbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_ranges                         = ["22","3389"]
  source_address_prefix                          = "*"
  destination_address_prefix                     = "VirtualNetwork"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-azurecloud-out" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Azure-Cloud-Out"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 110
  direction                                      = "Outbound"
  access                                         = "Allow"
  protocol                                       = "TCP"
  source_port_range                              = "*"
  destination_port_range                         = "443"
  source_address_prefix                          = "*"
  destination_address_prefix                     = "AzureCloud"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-bastioncomm-out" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Bastion-Communication-Out"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 120
  direction                                      = "Outbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_ranges                         = ["8080","5701"]
  source_address_prefix                          = "VirtualNetwork"
  destination_address_prefix                     = "VirtualNetwork"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

resource "azurerm_network_security_rule" "bastion-nsg-allow-getsessinfo-out" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg]

  name                                           = "Allow-Get-Session-Info-Out"
  description                                    = "Necessary for Azure Bastion"
  priority                                       = 130
  direction                                      = "Outbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "80"
  source_address_prefix                          = "*"
  destination_address_prefix                     = "Internet"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.bastion-snet-nsg.name
}

# Associations

resource "azurerm_subnet_network_security_group_association" "web-snet-nsg-assoc" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg,
                                                   azurerm_subnet.web-snet]

  subnet_id                                      = azurerm_subnet.web-snet.id
  network_security_group_id                      = azurerm_network_security_group.web-snet-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "bastion-snet-nsg-assoc" {
  depends_on                                     = [azurerm_network_security_group.bastion-snet-nsg,
                                                   azurerm_subnet.bastion-snet]

  subnet_id                                      = azurerm_subnet.bastion-snet.id
  network_security_group_id                      = azurerm_network_security_group.bastion-snet-nsg.id
}
