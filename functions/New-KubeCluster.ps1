function New-KubeCluster {
  [CmdletBinding()]
  param (
    [Int]$MasterCount = 3,
    [String]$MasterPrefix = "kubemaster",
    [String]$DomainName,
    [String]$KubeDataStoragePath,
    [String]$VmStoragePath,
    [String]$HyperVHost = ".",
    [String]$HyperVSwitch,
    [String]$BaseImageUrl = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-uefi1.img",
    [String]$ClusterDns,
    [String]$DnsServer,
    [String]$DhcpServer,
    [String]$DhcpScope,
    [String]$EtcdVersion = "3.2.18"
  )
  try {
    $baseimage = Get-BaseImage -BaseImageUrl $BaseImageUrl -VmStoragePath $VmStoragePath -HyperVHost $HyperVHost
    $basevhdx = Convert-CloudImg -CloudImgPath $baseimage -HyperVHost $HyperVHost

    $kubemasters = @()
    for ($i = 0; $i -lt $MasterCount; $i++) {
      $hostname = "${MasterPrefix}-$($i.ToString().PadLeft(2,'0'))"
      $ip = Get-KubeFreeIp -DhcpServer $DhcpServer -ScopeId $DhcpScope
      $master = [KubeMaster]::new(
        $hostname,
        $DomainName,
        $KubeDataStoragePath,
        $ip,
        $ClusterDns
      )
      New-KubeDhcpReservation -Name $master.FQDN -Mac $master.MacAddress -IP $master.IPAddress -DhcpServer $DhcpServer -ScopeId $DhcpScope
      New-KubeDns -Hostname $master.Hostname -IpAddress $master.IPAddress -DnsServer $DnsServer -ZoneName $DomainName
      $kubemasters += $master
    }
    foreach ($master in $kubemasters) {
      $folder = New-KubeVmFolder -VmStoragePath $VmStoragePath -VmName $master.Hostname -HyperVHost $HyperVHost
      $vhd = New-KubeVmVhd -VmFolderPath $folder -BaseImagePath $basevhdx -HyperVHost $HyperVHost
      $localiso = $master.CreateIso($Script:oscdimg)
      $iso = Copy-KubeIso -VmFolderPath $folder -Iso $localiso -HyperVHost $HyperVHost
      New-KubeVm -Name $master.Hostname -VmFolderPath $folder -SwitchName $HyperVSwitch -VhdPath $vhd -MacAddress $master.MacAddress -IsoPath $iso -HyperVHost $HyperVHost
      Start-VM -Name $master.Hostname -ComputerName $HyperVHost
    }
    Wait-EtcdCluster -IPAddress $kubemasters[0].IPAddress -CaPem "$($kubemasters[0].WorkingDir)\ca.pem" -ClientPem "$($kubemasters[0].WorkingDir)\client.pem" -ClientKey "$($kubemasters[0].WorkingDir)\client-key.pem" -ExpectedNodes $MasterCount
    Install-KubeControlPlane -Master $kubemasters[0]
    for ($i = 1; $i -lt $kubemasters.Count; $i++) {
      Copy-KubeCert -SourceMaster $kubemasters[0] -DestinationMaster $kubemasters[$i]
      Install-KubeControlPlane -Master $kubemasters[$i]
    }
    Install-KubeCni -Master $kubemasters[0]
    return $kubemasters
  }
  catch {
    $message = $_.Exception.Message
    $message += $_.InvocationInfo | Format-List *
    throw $message
  }
}