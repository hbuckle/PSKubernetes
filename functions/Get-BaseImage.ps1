function Get-BaseImage {
  [CmdletBinding()]
  param (
    [String]$BaseImageUrl,
    [String]$VmStoragePath,
    [String]$HyperVHost
  )
  $baseimage = Invoke-Command -ScriptBlock {
    param ($BaseImageUrl, $VmStoragePath)
    $filename = Split-Path $BaseImageUrl -Leaf
    $baseimage = Join-Path $VmStoragePath $filename
    if (-not(Test-Path $baseimage)) {
      $client = New-Object System.Net.WebClient
      $client.DownloadFile($BaseImageUrl, $baseimage)
    }
    Write-Output $baseimage
  } -ComputerName $HyperVHost -ArgumentList $BaseImageUrl, $VmStoragePath
  Write-Information "Base image: $baseimage"
  return $baseimage
}