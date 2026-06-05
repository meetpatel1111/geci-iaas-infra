resource "azurerm_public_ip" "tc_ip" {
  name                = "pip-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  domain_name_label = local.dns_label

  tags = var.tags
}
