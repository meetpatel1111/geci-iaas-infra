resource "azurerm_virtual_machine_extension" "bootstrap" {
  name                 = "geci-bootstrap"
  virtual_machine_id   = azurerm_windows_virtual_machine.tc_vm.id
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
