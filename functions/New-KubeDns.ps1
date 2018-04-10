function New-KubeDns {
  [CmdletBinding()]
  param (
    [String]$Hostname,
    [String]$IpAddress,
    [String]$DnsServer,
    [String]$ZoneName
  )
  $PSDefaultParameterValues = @{"*:ComputerName" = $DnsServer}
  $existing = Get-DnsServerResourceRecord -Name $Hostname -ZoneName $ZoneName -ErrorAction SilentlyContinue
  if ($null -eq $existing) {
    Add-DnsServerResourceRecordA -CreatePtr -Name $Hostname -IPv4Address $IpAddress -ZoneName $ZoneName
  } else {
    # Update IP
  }
  Write-Information "Created DNS record: ${Hostname}.${ZoneName} => ${IpAddress}"
}