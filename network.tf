# =============================================================================
# Virtual Network & Subnet
# =============================================================================
# One VNet per environment, each with its own non-overlapping CIDR:
#   QA:   10.0.6.0/24
#   Prod: 10.0.7.0/24
#
# A single subnet covers the entire VNet address space. GECI runs on a single
# VM so no subnet segmentation is required. If additional VMs or services are
# added in future, split into multiple subnets.
# =============================================================================

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_address_space]
}
