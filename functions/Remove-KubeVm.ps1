function Remove-KubeVm {
  [CmdletBinding()]
  param (
    [String]$Name,
    [String]$VmFolderPath,
    [String]$HyperVHost
  )
  $cimsession = New-CimSession -ComputerName $HyperVHost
  $PSDefaultParameterValues = @{"*:CimSession" = $cimsession}
  $exists = Get-VM -Name $Name -ErrorAction SilentlyContinue
  if ($null -ne $exists) {
    Stop-VM -Name $Name -TurnOff -Force
    Remove-VM -Name $Name -Force
    Remove-Item $VmFolderPath -Recurse -Force
  }
  Write-Information "Removed VM: ${Name}"
}