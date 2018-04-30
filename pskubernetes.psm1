$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
Set-StrictMode -Version Latest
$Script:etcdctl = "$PSScriptRoot\tools\etcdctl.exe"
Get-ChildItem "$PSScriptRoot\functions" -Filter "*.ps1" | ForEach-Object { . $_.FullName }
. "$PSScriptRoot\classes\KubeNode.ps1"
. "$PSScriptRoot\classes\KubeMaster.ps1"