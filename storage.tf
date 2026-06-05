# =============================================================================
# Diagnostic Storage Account
# =============================================================================
# Used exclusively for VM boot diagnostics. Boot diagnostics captures serial
# console output and screenshots of the VM during startup, which is essential
# for diagnosing boot failures when RDP is not yet available.
#
# Storage account name is derived from local.storage_name (hyphens stripped,
# st prefix and diag suffix added) to satisfy Azure's 3-24 char alphanumeric
# naming constraint.
#   QA:   stnaqausegecidiag
#   Prod: stpaprodusegecidag
# =============================================================================

resource "azurerm_storage_account" "diag" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # LRS is sufficient for diagnostics — no geo-redundancy needed

  min_tls_version            = "TLS1_2"
  https_traffic_only_enabled = true
  allow_blob_public_access   = false

  tags = var.tags
}
