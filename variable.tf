variable "project-tag" {
  description                     = "Project Tag"
  type                            = string
}
locals {
  tags = {
    project                       = "${var.project-tag}"
    managed-by                    = "terraform"
  }
}

variable "azure-resource-name" {
  description                     = "The resource prefix to deploy resources."
  type                            = string
}

variable "azure-resource-name-nospace" {
  description                     = "Resource prefix for resources that cannot accept a hypen in the name"
  type                            = string
}


variable "server-hostname" {
  description                     = "Server hostname"
  type                            = string
}

variable "location" {
  description                     = "The Azure Region to deploy resources."
  type                            = string
}

#variable "vpn-snet" {
#  description                     = "Subnet ID for vpn-snet"
#  type                            = string
#}

variable "vm-size" {
  description                     = "Size / SKU of the VM"
  type                            = string
}

variable "vm-admin" {
  description                     = "Local Administrator account of the VM"
  type                            = string
}

variable "data-disk-size" {
  description                     = "Data disk size in GB"
  type                            = string
}

variable "time-zone" {
  description                     = "Time Zone"
  type                            = string
}

variable "ansible-pwd" {
  default                         = ""
  description                     = "Ansible password"
  type                            = string
}


#####################################################################
######################## Hard Coded Variables #######################
#####################################################################

variable "azure-ad-tenant-id" {
  description                     = "The tenant ID for Azure Active Directory."
  type                            = string
  default                         = "a8059119-87be-4583-9a4e-7fc59ec6cbf9"
}

variable "tfcloud-obj-id" {
  description                     = "The object ID of the terraform-cloud service principle."
  type                            = string
  default                         = "6d34567d-d65d-486f-b8c8-615bfc0b5449"
}