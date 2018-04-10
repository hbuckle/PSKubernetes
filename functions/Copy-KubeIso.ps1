function Copy-KubeIso {
  [CmdletBinding()]
  param (
    [String]$VmFolderPath,
    [String]$Iso,
    [String]$HyperVHost
  )
  $session = New-PSSession -ComputerName $HyperVHost
  Copy-Item -ToSession $session -Path $Iso -Destination "$VmFolderPath\cidata.iso" -Force
  return "$VmFolderPath\cidata.iso"
}