if (-not(Test-Path "$PSScriptRoot\tools")) {
  $null = New-Item "$PSScriptRoot\tools" -ItemType Directory
}
if (-not(Test-Path "$PSScriptRoot\tools\cfssl.exe")) {
  Invoke-WebRequest "http://pkg.cfssl.org/R1.2/cfssl_windows-amd64.exe" -UseBasicParsing -OutFile "$PSScriptRoot\tools\cfssl.exe"
}