resource "azurerm_public_ip" "lbe-pip" {
  depends_on                        = [
                                      azurerm_resource_group.rg
                                      ]

  name                              = "${var.azure-resource-name}-lbe-pip"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  allocation_method                 = "Static"
  sku                               = "Basic"
  tags                              = "${(local.tags)}"
}

resource "azurerm_lb" "lbe" {
  depends_on                        = [
                                      azurerm_public_ip.lbe-pip
                                      ]

  name                              = "${var.azure-resource-name}-lbe"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.rg.name
  sku                               = "Basic"
  tags                              = "${(local.tags)}"

  frontend_ip_configuration {
    name                            = "loadbalancer-frontend"
    public_ip_address_id            = azurerm_public_ip.lbe-pip.id
  }
}

resource "azurerm_lb_probe" "lb-probe-lbe-http" {
  depends_on                        = [
                                      azurerm_lb.lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.lbe.id
  name                              = "${var.azure-resource-name}-lbe-http-healthprobe"
  protocol                          = "Tcp"
  port                              = 30000
  interval_in_seconds               = 5
  number_of_probes                  = 2
}

resource "azurerm_lb_probe" "lb-probe-lbe-tcp22" {
  depends_on                        = [
                                      azurerm_lb.lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.lbe.id
  name                              = "${var.azure-resource-name}-lbe-tcp22-healthprobe"
  protocol                          = "Tcp"
  port                              = 22
  interval_in_seconds               = 5
  number_of_probes                  = 2
}

resource "azurerm_lb_backend_address_pool" "lb-backendpool-lbe" {
  depends_on                        = [
                                      azurerm_lb.lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.lbe.id
  name                              = "${var.azure-resource-name}-lbe-backendpool"
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-nic-backend-01" {
  depends_on                        = [
                                      azurerm_lb_backend_address_pool.lb-backendpool-lbe,
                                      azurerm_network_interface.vm-01-nic
                                      ]

  network_interface_id              = azurerm_network_interface.vm-01-nic.id
  ip_configuration_name             = "base-ip"
  backend_address_pool_id           = azurerm_lb_backend_address_pool.lb-backendpool-lbe.id
}


resource "azurerm_lb_rule" "lb-rule-http-lbe" {
  depends_on                        = [
                                      azurerm_lb.lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.lbe.id
  name                              = "${var.azure-resource-name}-lbe-http-lbrule"
  protocol                          = "Tcp"
  frontend_port                     = 80
  backend_port                      = 30000
  frontend_ip_configuration_name    = "loadbalancer-frontend"
  backend_address_pool_ids          = [azurerm_lb_backend_address_pool.lb-backendpool-lbe.id]
  probe_id                          = azurerm_lb_probe.lb-probe-lbe-http.id
  load_distribution                 = "SourceIP"
  idle_timeout_in_minutes           = 4
  disable_outbound_snat             = true
}

resource "azurerm_lb_rule" "lb-rule-ssh-lbe" {
  depends_on                        = [
                                      azurerm_lb.lbe
                                      ]

  loadbalancer_id                   = azurerm_lb.lbe.id
  name                              = "${var.azure-resource-name}-lbe-ssh-lbrule"
  protocol                          = "Tcp"
  frontend_port                     = 22
  backend_port                      = 22
  frontend_ip_configuration_name    = "loadbalancer-frontend"
  backend_address_pool_ids          = [azurerm_lb_backend_address_pool.lb-backendpool-lbe.id]
  probe_id                          = azurerm_lb_probe.lb-probe-lbe-tcp22.id
  load_distribution                 = "SourceIP"
  idle_timeout_in_minutes           = 4
  disable_outbound_snat             = true
}
