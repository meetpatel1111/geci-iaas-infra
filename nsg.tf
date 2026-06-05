# =============================================================================
# Network Security Group
# =============================================================================
# Controls inbound traffic to the GECI VM. All traffic not explicitly allowed
# is denied by Azure's implicit default deny rule.
#
# Both rules restrict source to var.vpn_source_ips (Ivanti VPN gateway IPs).
# All GECI users — finance team and admins — must be on Ivanti VPN to reach
# the VM. Per-user access control (who can RDP vs who can use the app) is
# enforced by Windows Remote Desktop Users group and GECI application auth,
# not at the NSG level.
#
# source_port_range = "*" is always correct for inbound rules — it refers to
# the client's ephemeral/random outbound port, which cannot be predicted.
# =============================================================================

resource "azurerm_network_security_group" "geci_nsg" {
  name                = "nsg-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# GECI Web UI
# -----------------------------------------------------------------------------
# Allows finance team to access the GECI ASP.NET application via browser.
# Port is environment-specific (81 = QA, 88 = Prod) matching the IIS binding
# configured by the bootstrap extension.
# -----------------------------------------------------------------------------

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
  network_security_group_name = azurerm_network_security_group.geci_nsg.name
}

# -----------------------------------------------------------------------------
# RDP Access
# -----------------------------------------------------------------------------
# Allows admins to RDP into the VM for deployments and troubleshooting.
# Access is restricted to VPN IPs. Windows-level group membership controls
# which VPN users can actually complete an RDP session.
# -----------------------------------------------------------------------------

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
  network_security_group_name = azurerm_network_security_group.geci_nsg.name
}
