resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  storage_mode_type             = "GeoRedundant"
  public_network_access_enabled = false

  tags = var.tags
}
