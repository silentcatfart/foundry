variable "project-tag" {
  description                                       = "Project Tag"
  type                                              = string
  default                                           = "asa-ansible-test"
}

variable "resource-prefix" {
  description                                       = "Resource prefix"
  type                                              = string
  default                                           = "use-prd-cs-asa"
}

variable "location" {
  description                                       = "The Azure Region to deploy resources."
  type                                              = string
  default                                           = "eastus"
}

variable "vnet-address" {
  description                                       = "The CIDR of the virtual network."
  type                                              = string
  default                                           = "10.201.0.0/16"
}

variable "dns-servers" {
  description                                       = "DNS server IP addresses."
  type                                              = list
  default                                           = ["10.82.8.100", "10.81.8.100"]
}

variable "dns-servers-aad" {
  description                                       = "DNS server IP addresses Azure AD."
  type                                              = list
  default                                           = ["10.201.3.4", "10.201.3.5"]
}

variable "snet-web-address" {
  description                                       = "The CIDR of the web subnet."
  type                                              = string
  default                                           = "10.201.1.0/24"
}

variable "snet-bastion-address" {
  description                                       = "The address space for the hub's Bastion subnet."
  type                                              = string
  default                                           = "10.201.2.0/24"
}

variable "snet-ad-address" {
  description                                       = "The address space for the hub's ad subnet."
  type                                              = string
  default                                           = "10.201.3.0/24"
}

variable "azure-ad-tenant-id" {
  description                                       = "The tenant ID for Azure Active Directory."
  type                                              = string
  default                                           = "a0a8387d-cdb0-4454-9778-17d6e5437c61"
}

variable "tfcloud-obj-id" {
  description                                       = "The object ID of the terraform-cloud service principle."
  type                                              = string
  default                                           = "916306c2-9ad4-428b-b49f-fe09908c3654"
}
variable "techops-obj-id" {
  description                                       = "The object ID of DL-Techops."
  type                                              = string
  default                                           = "30b899d1-82e9-4ba6-ad86-4a70d309fcad"
}

variable "hostname" {
  description                                       = "Computer hostname"
  type                                              = string
  default                                           = "prdcsasa"
}

variable "alt-hostname" {
  description                                       = "Computer hostname"
  type                                              = string
  default                                           = "usecsasa"
}
variable "vm-size" {
  description                                       = "The size of the virtual machine."
  type                                              = string
  default                                           = "Standard_B2ms"
}

variable "vm-admin" {
  description                                       = "The admin username of the virtual machine."
  type                                              = string
  default                                           = "gatewayadmin"
}

variable "data-disk-size" {
  description                                       = "The size, in GB, of the data disk."
  type                                              = string
  default                                           = "32"
}

variable "timezone" {
  description                                       = "Timezone"
  type                                              = string
  default                                           = "Eastern Standard Time"
}

variable "db-data-disk-size" {
  description                                       = "The size, in GB, of the data disk."
  type                                              = string
  default                                           = "100"
}

variable "web-vm-vip01" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.101"
}

variable "web-vm-vip02" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.102"
}

variable "web-vm-vip03" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.103"
}

variable "web-vm-vip04" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.104"
}

variable "web-vm-baseip" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.10"
}

variable "web-vm-baseip2" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.11"
}

variable "web-vm-baseip3" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.12"
}

variable "web-vm-baseip4" {
  description                                       = "Statically assigned IP for the webstore VIP."
  type                                              = string
  default                                           = "10.201.1.13"
}

variable "image" {
  description                                       = "Custom 2012 R2 Image With WinRM enabled"
  type                                              = string
  default                                           = "/subscriptions/335c30dc-afe4-4ff9-aac1-eba040e29376/resourceGroups/use-prd-cs-image-rg/providers/Microsoft.Compute/images/use-prd-2012r2-winrm-vm-image"
}