variable "app_name" {
  type        = string
  description = "Application short name"
  default     = "geci"
}

variable "environment" {
  type        = string
  description = "Deployment environment (qa or prod)"
  validation {
    condition     = contains(["qa", "prod"], var.environment)
    error_message = "environment must be qa or prod"
  }
}

variable "env_prefix" {
  type        = string
  description = "Environment tier prefix used in resource naming (na for non-prod, pa for prod)"
  validation {
    condition     = contains(["na", "pa"], var.env_prefix)
    error_message = "env_prefix must be na or pa"
  }
}

variable "vnet_address_space" {
  type        = string
  description = "VNet address space CIDR"
  default     = "10.0.6.0/24"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM — do not use guessable names like admin/administrator/serveradmin"
}

variable "private_ip_address" {
  type        = string
  description = "Static private IP for the VM — must be within vnet_address_space"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
  sensitive   = true
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "East US"
}

variable "vm_size" {
  type        = string
  description = "VM size/sku"
  default     = "Standard_D4as_v5"
}


variable "vpn_source_ips" {
  type        = list(string)
  description = "Ivanti VPN gateway IPs — all GECI traffic (UI and RDP) flows through these. Per-user access control is handled by Windows groups and app auth, not the NSG."
}

variable "migration_source_snapshot_id" {
  type        = string
  description = "Source snapshot ID for disk migration (ARM resource ID)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Project   = "GECI"
    ManagedBy = "Terraform"
  }
}
