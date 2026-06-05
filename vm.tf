# =============================================================================
# GECI Virtual Machine
# =============================================================================
# Windows Server 2025 Datacenter VM matching the current on-prem hardware:
#   Processor : AMD EPYC 7763 (Standard_D4as_v5)
#   vCPUs     : 4
#   RAM       : 16 GB
#   OS Disk   : 256 GB Premium SSD
#
# The bootstrap extension (extensions.tf) runs immediately after provisioning
# to install IIS, .NET 3.5, and configure the GECI application directory.
#
# Deployment flow:
#   1. VM is created with a fresh Windows Server 2025 OS disk
#   2. Bootstrap extension installs required Windows features
#   3. Application code is deployed manually via RDP to local.app_path:
#        QA:   C:\inetpub\GMShare_New
#        Prod: C:\GMShare
# =============================================================================

resource "azurerm_windows_virtual_machine" "geci_vm" {
  name                = "vm-${local.name_suffix}"
  computer_name       = local.computer_name # max 15 chars — derived as geci-qa or geci-prod
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  license_type        = "Windows_Server" # Azure Hybrid Benefit — uses existing Windows Server licence

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.geci_nic.id
  ]

  # encryption_at_host encrypts OS disk, data disks, temp disk, and caches
  # at the physical host level — not just at the storage layer.
  encryption_at_host_enabled = true

  # AutomaticByOS applies Windows Update patches on the VM's own schedule.
  patch_mode = "AutomaticByOS"

  # SystemAssigned identity allows the VM to authenticate to Azure services
  # (e.g. Key Vault, Storage) without storing credentials anywhere.
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${local.name_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 256 # All app data (C:\GMShare) lives on the OS disk
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest" # Always pulls the latest patched image at deploy time
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  }

  tags = var.tags
}

# =============================================================================
# Migration Disk (optional)
# =============================================================================
# Only created when migration_source_snapshot_id is provided. Used to copy an
# existing VM's OS disk from another subscription or resource group into this
# environment. After creation the disk must be swapped manually via:
#   az vm stop --name <vm> --resource-group <rg>
#   az vm update --name <vm> --resource-group <rg> --os-disk <disk-id>
#   az vm start --name <vm> --resource-group <rg>
#
# prevent_destroy ensures this disk is never accidentally deleted by Terraform.
# Leave migration_source_snapshot_id as null for fresh deployments.
# =============================================================================

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
