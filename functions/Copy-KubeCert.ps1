function Copy-KubeCert {
  [CmdletBinding()]
  param (
    [KubeMaster]$SourceMaster,
    [KubeMaster]$DestinationMaster
  )
  @("/etc/kubernetes/pki/ca.crt",
    "/etc/kubernetes/pki/ca.key",
    "/etc/kubernetes/pki/sa.key",
    "/etc/kubernetes/pki/sa.pub"
  ) | ForEach-Object {
    Copy-RemoteFile -SourcePath $_ -DestinationPath $_ -SourceNode $SourceMaster -DestinationNode $DestinationMaster
  }
}