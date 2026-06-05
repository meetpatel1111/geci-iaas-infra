resource "azurerm_windows_virtual_machine" "tc_vm" {
  name                = "vm-${local.name_suffix}"
  computer_name       = local.computer_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  license_type        = "Windows_Server"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.tc_nic.id
  ]

  encryption_at_host_enabled = true
  patch_mode                 = "AutomaticByOS"

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${local.name_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 256
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  }

  tags = var.tags
}

# Step 2: Create migrated disk (copy from source subscription)
# This disk is created separately and swapped later via CLI
resource "azurerm_managed_disk" "migrated_os" {
  count = var.migration_source_snapshot_id != null ? 1 : 0

  name                 = "disk-${local.name_suffix}-migrated"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Copy"
  disk_size_gb         = 256
  source_resource_id   = var.migration_source_snapshot_id

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
