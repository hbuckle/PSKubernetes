function Copy-RemoteFile {
  [CmdletBinding()]
  param (
    [String]$SourcePath,
    [String]$DestinationPath,
    [KubeNode]$SourceNode,
    [KubeNode]$DestinationNode
  )
  Write-Information "Copying ${SourcePath} on $($SourceNode.Hostname) to ${DestinationPath} on $($DestinationNode.Hostname)"
  $content = $SourceNode.InvokeSshCommand("sudo cat ${SourcePath}")
  $null = $DestinationNode.InvokeSshCommand("echo '${content}' | sudo tee ${DestinationPath} > /dev/null")
}