output "public_ips" {
  value = { for k, pip in azurerm_public_ip.vm : k => pip.ip_address }
}
