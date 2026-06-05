resource "azurerm_network_security_group" "tc_nsg" {
  name                = "nsg-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "app" {
  name                        = "App_Port_${local.app_port}"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(local.app_port)
  source_address_prefixes     = var.vpn_source_ips
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tc_nsg.name
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "RDP"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = var.vpn_source_ips
  source_port_range           = "*"
  destination_port_range      = "3389"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tc_nsg.name
}
