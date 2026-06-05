# =============================================================================
# Public IP Address
# =============================================================================
# Static Standard SKU public IP attached to the GECI VM NIC.
# Standard SKU is required when pairing with a Standard SKU load balancer
# or when zone-redundancy is needed in future.
#
# This public IP is the current access path for VPN users reaching the VM.
# If a VPN Gateway or ExpressRoute is configured to route traffic into this
# VNet privately, this resource and its reference in nic.tf can be removed
# to eliminate all internet-facing exposure.
# =============================================================================

resource "azurerm_public_ip" "geci_ip" {
  name                = "pip-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  # DNS label makes the IP reachable via a stable FQDN:
  #   geci-na-qa-use.eastus.cloudapp.azure.com  (QA)
  #   geci-pa-prod-use.eastus.cloudapp.azure.com (Prod)
  domain_name_label = local.dns_label

  tags = var.tags
}
