# =============================================================================
# Variables
# =============================================================================
# All inputs are defined here. Environment-specific values are set in:
#   qa.tfvars   — QA environment
#   prod.tfvars — Production environment
#
# Sensitive values (admin_password) are NEVER stored in tfvars files.
# They are injected at runtime via the TF_VAR_admin_password environment
# variable, which is sourced from GitHub Actions secrets in CI.
# =============================================================================

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------

variable "app_name" {
  type        = string
  description = "Application short name — used in all resource names"
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

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "vnet_address_space" {
  type        = string
  description = "VNet address space CIDR — must not overlap with other VNets or on-prem ranges"
  default     = "10.0.6.0/24"
}

variable "private_ip_address" {
  type        = string
  description = "Static private IP for the GECI VM — must be within vnet_address_space. Azure reserves .0-.3, use .4 onwards"
}

variable "vpn_source_ips" {
  type        = list(string)
  description = "Ivanti VPN gateway IPs — all GECI traffic (UI and RDP) flows through these. Per-user access control is handled by Windows groups and app-level auth, not the NSG"
}

# -----------------------------------------------------------------------------
# VM
# -----------------------------------------------------------------------------

variable "admin_username" {
  type        = string
  description = "Admin username for the GECI VM — do not use guessable names like admin/administrator/serveradmin"
}

variable "admin_password" {
  type        = string
  description = "Admin password — injected via TF_VAR_admin_password env var. Never store in tfvars files"
  sensitive   = true
}

variable "vm_size" {
  type        = string
  description = "Azure VM size — Standard_D4as_v7 (4 vCPU, 16 GB RAM, consistent CPU) for GECI production workload"
  default     = "Standard_D4as_v7"
}

variable "migration_source_snapshot_id" {
  type        = string
  description = "ARM resource ID of a snapshot to copy as the OS disk. Leave null for fresh deployments — only set when migrating from an existing VM"
  default     = null
}

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "East US"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources — override per environment in tfvars to include Environment tag"
  default = {
    Project   = "GECI"
    ManagedBy = "Terraform"
  }
}
