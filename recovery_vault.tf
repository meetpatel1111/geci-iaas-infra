# =============================================================================
# Recovery Services Vault
# =============================================================================
# Provides backup and restore capability for the GECI VM.
# GeoRedundant storage ensures backup data is replicated to a secondary Azure
# region, protecting against regional outages.
#
# Public network access is disabled — the vault is managed through Azure RBAC
# and the Azure portal/CLI only. No public endpoint exposure.
#
# NEXT STEP: A backup policy and azurerm_backup_protected_vm resource must be
# added to actually start backing up the GECI VM. The vault alone does not
# trigger any backups without a policy attached.
# =============================================================================

resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  storage_mode_type             = "GeoRedundant"
  public_network_access_enabled = false

  tags = var.tags
}
