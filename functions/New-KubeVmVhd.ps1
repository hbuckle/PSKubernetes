function New-KubeVmVhd {
  [CmdletBinding()]
  param (
    [String]$VmFolderPath,
    [String]$BaseImagePath,
    [String]$HyperVHost
  )
  $cimsession = New-CimSession -ComputerName $HyperVHost
  $PSDefaultParameterValues = @{"*:CimSession" = $cimsession}
  $vhdx = "${VmFolderPath}\os.vhdx"
  $exists = Get-VHD -Path $vhdx -ErrorAction SilentlyContinue
  if ($null -eq $exists) {
    $null = New-VHD -Path $vhdx -ParentPath $BaseImagePath -Differencing -SizeBytes 30GB
  }
  Write-Information "Created VHD: ${vhdx}"
  return $vhdx
}