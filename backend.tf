# =============================================================================
# Remote State Backend
# =============================================================================
# Terraform state is stored remotely in Azure Blob Storage so all team members
# and CI/CD runs share the same state. Backend values (resource group, storage
# account, container, key) are passed at runtime via terraform init -backend-config.
#
# The prebootstrap.sh script creates the storage account and container before
# terraform init runs. See .github/workflows/terraform.yml for how this is wired.
#
# State files are environment-scoped:
#   geci/qa/geci.tfstate
#   geci/prod/geci.tfstate
# =============================================================================

terraform {
  backend "azurerm" {}
}
