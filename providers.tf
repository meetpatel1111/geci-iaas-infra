# =============================================================================
# Provider & Locals
# =============================================================================
# Pins the AzureRM provider to a specific version to prevent unexpected
# upgrades from breaking the deployment.
# =============================================================================

terraform {
  required_version = ">= 1.15.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.75.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# =============================================================================
# Naming Convention
# =============================================================================
# All Azure resource names are derived from these locals — nothing is hardcoded
# in individual resource files. The pattern is:
#
#   <resource-type>-<env_prefix>-<environment>-use-<app_name>
#
# Examples:
#   vm-na-qa-use-geci      (QA virtual machine)
#   vm-pa-prod-use-geci    (Production virtual machine)
#   nsg-na-qa-use-geci     (QA network security group)
#
# env_prefix  — na (non-prod) or pa (prod), set in tfvars
# environment — qa or prod, set in tfvars
# use         — US East region, hardcoded as all resources are in East US
# app_name    — geci, default in variables.tf
#
# app_port    — IIS binding port: 81 for QA, 88 for prod (matches on-prem setup)
# app_path    — IIS physical path: C:\inetpub\GMShare_New (QA), C:\GMShare (prod)
# storage_name — globally unique storage account name, derived by stripping hyphens
# =============================================================================

locals {
  name_infix    = "${var.env_prefix}-${var.environment}-use"
  name_suffix   = "${local.name_infix}-${var.app_name}"
  computer_name = "${var.app_name}-${var.environment}"
  dns_label     = "${var.app_name}-${local.name_infix}"
  storage_name  = "st${replace(local.name_suffix, "-", "")}diag"
  app_port      = var.environment == "prod" ? 88 : 81
  app_path      = var.environment == "prod" ? "C:\\GMShare" : "C:\\inetpub\\GMShare_New"
}

# =============================================================================
# Resource Group
# =============================================================================
# Single resource group per environment. All GECI resources live here.
# =============================================================================

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_suffix}"
  location = var.location

  tags = var.tags
}
