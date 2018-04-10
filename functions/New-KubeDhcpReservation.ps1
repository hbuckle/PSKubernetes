function New-KubeDhcpReservation {
  [CmdletBinding()]
  param (
    [String]$Name,
    [String]$Mac,
    [String]$IP,
    [String]$DhcpServer,
    [String]$ScopeId
  )
  $PSDefaultParameterValues = @{"*:ComputerName" = $DhcpServer}
  $existing = Get-DhcpServerv4Lease -ScopeId $ScopeId -ClientId $Mac.ToLower() -ErrorAction SilentlyContinue
  if ($null -eq $existing) {
    Add-DhcpServerv4Reservation -ScopeId $ScopeId -IPAddress $ip -ClientId $Mac.ToLower() -Name $Name -Type "Dhcp"
    Add-DhcpServerv4Lease -ScopeId $ScopeId -IPAddress $ip -ClientId $Mac.ToLower() -AddressState "ActiveReservation" -ClientType "Dhcp" -HostName $Name
  }
  Write-Information "Created DHCP reservation: ${Mac} => ${IP}"
}