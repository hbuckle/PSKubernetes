function Get-KubeFreeIP {
  [CmdletBinding()]
  param (
    [String]$DhcpServer,
    [String]$ScopeId
  )
  $PSDefaultParameterValues = @{"*:ComputerName" = $DhcpServer}
  $ip = Get-DhcpServerv4FreeIPAddress -ScopeId $ScopeId -NumAddress 1
  Write-Information "Found free IP: ${ip}"
  return $ip
}