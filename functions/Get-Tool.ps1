function Get-Tool {
  [CmdletBinding()]
  param (
    [String]$EtcdVersion
  )
  $tools = "$(Split-Path $PSScriptRoot -Parent)\tools"
  if (-not(Test-Path $tools)) {
    $null = New-Item $tools -ItemType Directory
  }
  $etcdurl = "https://github.com/coreos/etcd/releases/download/v${EtcdVersion}/etcd-v${EtcdVersion}-windows-amd64.zip"
  if (-not(Test-Path "$tools\etcd-v${EtcdVersion}-windows-amd64.zip")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $client = [System.Net.WebClient]::new()
    $client.DownloadFile($etcdurl, "$tools\etcd-v${EtcdVersion}-windows-amd64.zip")
    Expand-Archive -Path "$tools\etcd-v${EtcdVersion}-windows-amd64.zip" -DestinationPath $tools
  }
  $Script:etcdctl = "$tools\etcd-v${EtcdVersion}-windows-amd64\etcdctl.exe"
}