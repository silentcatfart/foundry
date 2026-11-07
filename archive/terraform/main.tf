locals {
  tags = {
    project    = var.project_tag
    managed-by = "terraform"
  }

  inbound_rules = {
    Allow-SSH-Inbound = {
      priority = 160, protocol = "Tcp", ports = ["22"], sources = var.ssh_source_ips
    }
    Allow-Foundry-Inbound = {
      priority = 170, protocol = "Tcp", ports = ["80", "443"], sources = ["Internet"]
    }
    Allow-Livekit-Tcp-Inbound = {
      priority = 180, protocol = "Tcp", ports = ["7881"], sources = ["Internet"]
    }
    Allow-Livekit-Udp-Inbound = {
      priority = 190, protocol = "Udp", ports = ["3478", "50000-60000"], sources = ["Internet"]
    }
    Allow-Intra-Subnet-Inbound = {
      priority = 200, protocol = "*", ports = ["*"], sources = [var.subnet_cidr]
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name_prefix}-rg"
  location = var.location
  tags     = local.tags
}

# ---------------- Network ----------------

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "web" {
  name                 = "${var.name_prefix}-web-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "web" {
  name                = "${var.name_prefix}-web-snet-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = local.inbound_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_ranges    = security_rule.value.ports
      source_address_prefixes    = security_rule.value.sources
      destination_address_prefix = var.subnet_cidr
    }
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Web-Browsing-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = var.subnet_cidr
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "Deny-All-Internet-Outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_cidr
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# ---------------- Storage ----------------

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "GRS"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}
