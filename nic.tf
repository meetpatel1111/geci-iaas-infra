# =============================================================================
# Network Interface
# =============================================================================
# The GECI VM has a single NIC with:
#   - Static private IP (so the VM IP never changes on restart)
#   - Public IP attached (required while direct VPN-to-VNet routing is not set up)
#
# NOTE: If Ivanti VPN is configured with a site-to-site or point-to-site
# VPN Gateway into this VNet, remove public_ip_address_id and access the VM
# via private IP only. That eliminates any internet exposure.
# =============================================================================

resource "azurerm_network_interface" "geci_nic" {
  name                = "nic-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = azurerm_public_ip.geci_ip.id
  }

  tags = var.tags
}

# Associate the NSG with this NIC so security rules are enforced at the VM level.
resource "azurerm_network_interface_security_group_association" "geci_assoc" {
  network_interface_id      = azurerm_network_interface.geci_nic.id
  network_security_group_id = azurerm_network_security_group.geci_nsg.id
}
