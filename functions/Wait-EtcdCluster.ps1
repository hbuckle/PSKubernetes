function Wait-EtcdCluster {
  [CmdletBinding()]
  param (
    [Array]$IPAddress,
    [String]$CaPem,
    [String]$ClientPem,
    [String]$clientKey,
    [Int]$ExpectedNodes
  )
  $continue = $true
  while ($continue) {
    try {
      $etcdctlargs = @(
        "--output json",
        "--endpoint https://${IPAddress}:2379",
        "--ca-file $CaPem",
        "--cert-file $ClientPem",
        "--key-file $ClientKey",
        "cluster-health"
      ) -join " "
      $result = Start-ProcessWithOutput -FilePath $Script:etcdctl -Arguments $etcdctlargs
      $healthy = @($result -split "`n" | Where-Object { $_ -match "got healthy result" })
      if ($healthy.Count -eq $ExpectedNodes) {
        Write-Information $result
        $continue = $false
      }
      else {
        Write-Information "Waiting for etcd cluster: $($healthy.Count) of ${ExpectedNodes}"
        Start-Sleep -Seconds 20
      }
    }
    catch {
      Write-Information "Waiting for etcd cluster: $($_.Exception.Message)"
      Start-Sleep -Seconds 20
    }
  }
}