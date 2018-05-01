function Remove-KubeDhcpReservation {
  [CmdletBinding()]
  param (
    [String]$Mac,
    [String]$DhcpServer,
    [String]$ScopeId
  )
  $PSDefaultParameterValues = @{"*:ComputerName" = $DhcpServer}
  Get-DhcpServerv4Reservation -ScopeId $ScopeId |
    Where-Object { $_.ClientId.ToLower().Replace("-", "") -eq $Mac.ToLower() } | Remove-DhcpServerv4Reservation -Confirm:$false
  Get-DhcpServerv4Lease -ScopeId $ScopeId |
    Where-Object { $_.ClientId.ToLower().Replace("-", "") -eq $Mac.ToLower() } | Remove-DhcpServerv4Lease -Confirm:$false
}