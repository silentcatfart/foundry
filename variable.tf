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

variable "snet-1-cidr" {
  description                     = "Subnet 1 address range"
  type                            = string
}

variable "snet-2-cidr" {
  description                     = "Subnet 2 address range"
  type                            = string
}

variable "snet-3-cidr" {
  description                     = "Subnet 3 address range"
  type                            = string
}

variable "snet-4-cidr" {
  description                     = "Subnet 4 address range"
  type                            = string
}

variable "snet-5-cidr" {
  description                     = "Subnet 5 address range"
  type                            = string
}

variable "snet-6-cidr" {
  description                     = "Subnet 6 address range"
  type                            = string
}

variable "snet-7-cidr" {
  description                     = "Subnet 7 address range"
  type                            = string
}

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