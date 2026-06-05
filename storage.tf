resource "azurerm_storage_account" "diag" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version           = "TLS1_2"
  https_traffic_only_enabled = true
  allow_blob_public_access  = false

  tags = var.tags
}
