# NSGs
resource "azurerm_network_security_group" "web-snet-nsg" {
  depends_on                        		         = [azurerm_resource_group.rg]

  name                                           = "${var.azure-resource-name}-web-snet-nsg"
  location                                       = var.location
  resource_group_name                            = azurerm_resource_group.rg.name

  tags = {
    managed-by                                   = "terraform"
    project                                      = var.project-tag
  }
}

# Rules
resource "azurerm_network_security_rule" "web-snet-nsg-ssh-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-SSH-Inbound"
  description                                    = "Needed for administering the server"
  priority                                       = 160
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_ranges                        = ["22"]
#  source_address_prefix                          = "Internet"
  source_address_prefix                          = "71.230.53.86"
  destination_address_prefix                     = "${var.snet-0-cidr}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-foundry-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-Foundry-Inbound"
  description                                    = "Ports needed to access Foundry"
  priority                                       = 170
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "Tcp"
  source_port_range                              = "*"
  destination_port_ranges                        = ["30000","80","443"]
  source_address_prefix                          = "Internet"
  destination_address_prefix                     = "${var.snet-0-cidr}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-livekit-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-Livekit-Inbound"
  description                                    = "Ports needed to access LiveKit"
  priority                                       = 180
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_ranges                        = ["50000-60000","443","80","7881","3478"]
  source_address_prefix                          = "Internet"
  destination_address_prefix                     = "${var.snet-0-cidr}"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

resource "azurerm_network_security_rule" "web-snet-nsg-intra-subnet-in" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg]

  name                                           = "Allow-Intra-Subnet-Inbound"
  description                                    = "Allow traffic between VMs within the same subnet"
  priority                                       = 200
  direction                                      = "Inbound"
  access                                         = "Allow"
  protocol                                       = "*"
  source_port_range                              = "*"
  destination_port_range                         = "*"
  source_address_prefixes                        = ["${var.snet-0-cidr}"]
  destination_address_prefix                     = "${var.snet-0-cidr}"
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
  source_address_prefix                          = "${var.snet-0-cidr}"
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
  source_address_prefix                          = "${var.snet-0-cidr}"
  destination_address_prefix                     = "Internet"
  resource_group_name                            = azurerm_resource_group.rg.name
  network_security_group_name                    = azurerm_network_security_group.web-snet-nsg.name
}

# Associations
resource "azurerm_subnet_network_security_group_association" "web-snet-nsg-assoc" {
  depends_on                                     = [azurerm_network_security_group.web-snet-nsg,
                                                   azurerm_subnet.web-snet]

  subnet_id                                      = azurerm_subnet.web-snet.id
  network_security_group_id                      = azurerm_network_security_group.web-snet-nsg.id
}