@{
  RootModule             = 'pskubernetes.psm1'
  NestedModules          = @(
    "cfssl\cfssl.psm1"
  )
  ModuleVersion          = '0.0.1'
  GUID                   = 'd331ebce-e6bd-439f-83d2-607c1d0200d5'
  Author                 = 'Henry Buckle'
  PowerShellVersion      = '5.1'
  DotNetFrameworkVersion = '4.5'
  RequiredModules        = @(
    "Hyper-V",
    "DnsServer",
    "DhcpServer",
    "powershell-yaml"
  )
  FunctionsToExport      = @(
    "New-KubeCluster"
  )
}