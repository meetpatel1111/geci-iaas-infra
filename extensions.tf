# =============================================================================
# Bootstrap Extension
# =============================================================================
# Runs a PowerShell script on the VM immediately after provisioning.
# Uses CustomScriptExtension (Microsoft.Compute) which executes as SYSTEM.
#
# The entire script runs as a single PowerShell session with
# $ErrorActionPreference='Stop' — any failure aborts all subsequent steps,
# preventing a partially configured VM from appearing healthy.
#
# Steps performed:
#   1. Install Windows features:
#        - Net-Framework-Core  (.NET 3.5 — required by GECI ASP.NET app)
#        - Web-Server          (IIS)
#        - Web-Asp-Net45       (ASP.NET handler for ASPX pages)
#        - Web-Net-Ext45       (.NET Extensibility)
#        - Web-ISAPI-Ext       (ISAPI Extensions — required for ASP.NET)
#        - Web-ISAPI-Filter    (ISAPI Filters — required for ASP.NET)
#        - Web-Mgmt-Console    (IIS Manager UI for manual deployments via RDP)
#
#   2. Create the application directory:
#        QA:   C:\inetpub\GMShare_New
#        Prod: C:\GMShare
#
#   3. Configure IIS:
#        - Remove the Default Web Site
#        - Create a new site named GECI on the correct port and path:
#            QA:   port 81  → C:\inetpub\GMShare_New
#            Prod: port 88  → C:\GMShare
#
# After the bootstrap runs, deploy the GECI application code by:
#   1. RDP into the VM
#   2. Open Visual Studio → Clean → Build the GMeSAP.sln solution
#   3. Copy the compiled .dll from bin/ and .aspx files to local.app_path
# =============================================================================

resource "azurerm_virtual_machine_extension" "bootstrap" {
  name                 = "geci-bootstrap"
  virtual_machine_id   = azurerm_windows_virtual_machine.geci_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  # Single PowerShell session — $ErrorActionPreference='Stop' aborts on any failure.
  settings = jsonencode({
    commandToExecute = join("", [
      "powershell -ExecutionPolicy Bypass -Command \"& { ",
      "$ErrorActionPreference='Stop'; ",
      "Install-WindowsFeature -Name Net-Framework-Core,Web-Server,Web-Asp-Net45,Web-Net-Ext45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Mgmt-Console -IncludeManagementTools; ",
      "New-Item -ItemType Directory -Force -Path '${local.app_path}'; ",
      "Import-Module WebAdministration; ",
      "Remove-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue; ",
      "New-WebSite -Name 'GECI' -Port ${local.app_port} -PhysicalPath '${local.app_path}' -Force ",
      "}\""
    ])
  })

  tags = var.tags
}
