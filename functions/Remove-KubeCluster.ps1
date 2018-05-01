function Remove-KubeCluster {
  [CmdletBinding()]
  param (
    [KubeMaster[]]$KubeMasters,
    [String]$VmStoragePath,
    [String]$HyperVHost = ".",
    [String]$ClusterDns,
    [String]$DnsServer,
    [String]$DhcpServer,
    [String]$DhcpScope
  )
  try {
    foreach ($master in $KubeMasters) {
      Remove-KubeVm -Name $master.VMName -VmFolderPath "${VmStoragePath}\$($master.VMName)" -HyperVHost $HyperVHost
      Remove-KubeDhcpReservation -Mac $master.MacAddress -DhcpServer $DhcpServer -ScopeId $DhcpScope
    }
  }
  catch {
    Write-Information "An error occured in   : $($_.InvocationInfo.ScriptName)" 
    Write-Information "The error was at line : $($_.InvocationInfo.ScriptLineNumber)"
    throw $_.Exception.Message
  }
}