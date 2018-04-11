# Run each test in a new session to get around PowerShell class caching
Get-ChildItem $PSScriptRoot -Filter "*.tests.ps1" | ForEach-Object {
  Start-Job -ScriptBlock {
    param($script)
    Invoke-Pester -Script $script
  } -ArgumentList $_.FullName | Receive-Job -AutoRemoveJob -Wait
}