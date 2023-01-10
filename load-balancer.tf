resource "azurerm_public_ip" "core-vpn-lbe-pip" {
  depends_on                        = [
                                      azurerm_resource_group.core-vm-rg
                                      ]

  name                              = "${var.azure-resource-name}-core-vpn-lbe-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.core-vm-rg.name
  allocation_method                 = "Static"
  sku                               = "Standard"
  tags                              = "${(local.tags)}"
}

resource "azurerm_lb" "core-vpn-lbe" {
  depends_on                        = [
                                      azurerm_public_ip.core-vpn-lbe-pip
                                      ]

  name                              = "${var.azure-resource-name}-core-vpn-lbe"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.core-vm-rg.name
  sku                               = "Standard"
  tags                              = "${(local.tags)}"

  frontend_ip_configuration {
    name                            = "loadbalancer-frontend"
    public_ip_address_id            = azurerm_public_ip.core-vpn-lbe-pip.id
  }
}

resource "azurerm_lb_probe" "lb-probe-core-vpn-lbe-https" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-https-healthprobe"
  protocol                          = "Tcp"
  port                              = 443
  interval_in_seconds               = 5
  number_of_probes                  = 2
}

resource "azurerm_lb_probe" "lb-probe-core-vpn-lbe-tcp943" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-tcp943-healthprobe"
  protocol                          = "Tcp"
  port                              = 943
  interval_in_seconds               = 5
  number_of_probes                  = 2
}

resource "azurerm_lb_backend_address_pool" "lb-backendpool-core-vpn-lbe" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-backendpool"
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-nic-core-vpn-backend-01" {
  depends_on                        = [
                                      azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe,
                                      azurerm_network_interface.core-vpn-01-vm-nic
                                      ]

  network_interface_id              = azurerm_network_interface.core-vpn-01-vm-nic.id
  ip_configuration_name             = "base-ip"
  backend_address_pool_id           = azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-nic-core-vpn-backend-02" {
  depends_on                        = [
                                      azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe,
                                      azurerm_network_interface.core-vpn-02-vm-nic
                                      ]

  network_interface_id              = azurerm_network_interface.core-vpn-02-vm-nic.id
  ip_configuration_name             = "base-ip"
  backend_address_pool_id           = azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id
}

resource "azurerm_lb_rule" "lb-rule-https-core-vpn-lbe" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-https-lbrule"
  protocol                          = "Tcp"
  frontend_port                     = 443
  backend_port                      = 443
  frontend_ip_configuration_name    = "loadbalancer-frontend"
  backend_address_pool_ids          = [azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id]
  probe_id                          = azurerm_lb_probe.lb-probe-core-vpn-lbe-https.id
  load_distribution                 = "SourceIP"
  idle_timeout_in_minutes           = 4
  disable_outbound_snat             = true
}

resource "azurerm_lb_rule" "lb-rule-udp1194-core-vpn-lbe" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-udp1194-lbrule"
  protocol                          = "Udp"
  frontend_port                     = 1194
  backend_port                      = 1194
  frontend_ip_configuration_name    = "loadbalancer-frontend"
  backend_address_pool_ids          = [azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id]
  load_distribution                 = "SourceIP"
  idle_timeout_in_minutes           = 4
  disable_outbound_snat             = true
}

resource "azurerm_lb_rule" "lb-rule-tcp943-core-vpn-lbe" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  name                              = "${var.azure-resource-name}-core-vpn-lbe-tcp943-lbrule"
  protocol                          = "Tcp"
  frontend_port                     = 943
  backend_port                      = 943
  frontend_ip_configuration_name    = "loadbalancer-frontend"
  backend_address_pool_ids          = [azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id]
  probe_id                          = azurerm_lb_probe.lb-probe-core-vpn-lbe-tcp943.id
  load_distribution                 = "SourceIP"
  idle_timeout_in_minutes           = 4
  disable_outbound_snat             = true
}

resource "azurerm_lb_outbound_rule" "lb-outbound-rule-vpn-lbe" {
  depends_on                        = [
                                      azurerm_lb.core-vpn-lbe
                                      ]

  name                              = "OutboundRule"
  loadbalancer_id                   = azurerm_lb.core-vpn-lbe.id
  protocol                          = "All"
  backend_address_pool_id           = azurerm_lb_backend_address_pool.lb-backendpool-core-vpn-lbe.id

  frontend_ip_configuration {
    name                            = "loadbalancer-frontend"
  }
}