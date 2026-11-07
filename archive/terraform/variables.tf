variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus2"
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "foundry"
}

variable "storage_account_name" {
  description = "Globally unique storage account name (no hyphens)."
  type        = string
  default     = "fndryst"
}

variable "project_tag" {
  type    = string
  default = "Foundry VTT"
}

variable "admin_username" {
  type    = string
  default = "foundry"
}

variable "admin_public_key_path" {
  type    = string
  default = "./ssh-key/id_rsa-foundry.pub"
}

variable "ssh_source_ips" {
  description = "Public IPs/CIDRs allowed to SSH in."
  type        = list(string)
}

variable "vnet_cidr" {
  type    = string
  default = "10.250.0.0/24"
}

variable "subnet_cidr" {
  type    = string
  default = "10.250.0.0/24"
}

variable "vms" {
  description = "VMs to deploy, keyed by short name. Set livekit = true to attach the LiveKit cloud-init."
  type = map(object({
    size           = string
    hostname       = string
    data_disk_size = number
    livekit        = optional(bool, false)
  }))
}

variable "livekit_api_key" {
  description = "LiveKit API key (only used when a VM has livekit = true)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "livekit_api_secret" {
  type      = string
  default   = ""
  sensitive = true
}
