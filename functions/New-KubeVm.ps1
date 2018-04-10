function New-KubeVm {
  [CmdletBinding()]
  param (
    [String]$Name,
    [String]$VmFolderPath,
    [String]$SwitchName,
    [String]$VhdPath,
    [String]$MacAddress,
    [String]$IsoPath,
    [String]$HyperVHost
  )
  $cimsession = New-CimSession -ComputerName $HyperVHost
  $PSDefaultParameterValues = @{"*:CimSession" = $cimsession}
  $exists = Get-VM -Name $Name -ErrorAction SilentlyContinue
  if ($null -eq $exists) {
    $vm = New-VM -Name $Name -Generation 2 -MemoryStartupBytes 1GB -VHDPath $VhdPath -SwitchName $SwitchName -Path $VmFolderPath
    Set-VMProcessor -Count 2 -VMName $vm.Name
    Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $vm.Name
    Set-VMMemory -DynamicMemoryEnabled $true -VMName $vm.Name
    Set-VMFirmware -SecureBootTemplate "MicrosoftUEFICertificateAuthority" -VMName $vm.Name
    Set-VMComPort -Number 1 -Path "\\.\pipe\$($vm.Name)-COM1" -VMName $vm.Name
    Set-VMNetworkAdapter -VMName $vm.Name -StaticMacAddress $MacAddress
    Add-VMDvdDrive -VMName $vm.Name -Path $IsoPath
  }
  Write-Information "Created VM: ${Name}"
}