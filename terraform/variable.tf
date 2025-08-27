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

variable "location" {
  description                     = "The Azure Region to deploy resources."
  type                            = string
}

variable "my-public-ip" {
  description                     = "My public IP address"
  type                            = string
}

variable "vnet-cidr" {
  description                     = "VNET Address range"
  type                            = string
}

variable "snet-0-cidr" {
  description                     = "Subnet 0 address range"
  type                            = string
}

variable "cloudflare-cidr" {
  description                     = "Cloudflare address range"
  type                            = list
}

variable "vm-01-size" {
  description                     = "Size / SKU of the VM"
  type                            = string
}

variable "vm-02-size" {
  description                     = "Size / SKU of the VM"
  type                            = string
}

variable "vm-03-size" {
  description                     = "Size / SKU of the VM"
  type                            = string
}

variable "vm-01-hostname" {
  description                     = "OS hostname"
  type                            = string
}

variable "vm-02-hostname" {
  description                     = "OS hostname"
  type                            = string
}

variable "vm-03-hostname" {
  description                     = "OS hostname"
  type                            = string
}

variable "vm-01-data-disk-size" {
  description                     = "Data disk size in GB"
  type                            = string
}

variable "vm-02-data-disk-size" {
  description                     = "Data disk size in GB"
  type                            = string
}

variable "vm-03-data-disk-size" {
  description                     = "Data disk size in GB"
  type                            = string
}

variable "vm-admin" {
  description                     = "Local Administrator account of the VM"
  type                            = string
}

variable "time-zone" {
  description                     = "Time Zone"
  type                            = string
}