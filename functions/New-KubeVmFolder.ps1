function New-KubeVmFolder {
  [CmdletBinding()]
  param (
    [string]$VmStoragePath,
    [String]$VmName,
    [String]$HyperVHost
  )
  $vmpath = Invoke-Command -ScriptBlock {
    param ($VmStoragePath, $VmName)
    if (-not(Test-Path $VmStoragePath)) {
      $null = New-Item $VmStoragePath -ItemType Directory
    }
    $vmpath = Join-Path $VmStoragePath $VmName
    if (-not(Test-Path $vmpath)) {
      $null = New-Item $vmpath -ItemType Directory
    }
    Write-Output $vmpath
  } -ComputerName $HyperVHost -ArgumentList $VmStoragePath, $VmName
  Write-Information "Created VM path: ${vmpath}"
  return $vmpath
}