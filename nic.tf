resource "azurerm_network_interface" "tc_nic" {
  name                = "nic-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = azurerm_public_ip.tc_ip.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.tc_nic.id
  network_security_group_id = azurerm_network_security_group.tc_nsg.id
}
