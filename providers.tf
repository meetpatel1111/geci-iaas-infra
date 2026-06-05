terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.68.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  name_infix    = "${var.env_prefix}-${var.environment}-use"
  name_suffix   = "${local.name_infix}-${var.app_name}"
  computer_name = "${var.app_name}-${var.environment}"
  dns_label     = "${var.app_name}-${local.name_infix}"
  storage_name  = "st${replace(local.name_suffix, "-", "")}diag"
  app_port      = var.environment == "prod" ? 88 : 81
  app_path      = var.environment == "prod" ? "C:\\GMShare" : "C:\\inetpub\\GMShare_New"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_suffix}"
  location = var.location

  tags = var.tags
}
