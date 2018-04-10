$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
Set-StrictMode -Version Latest
Get-ChildItem $PSScriptRoot -Recurse -Filter "*.ps1" | ForEach-Object { . $($_.FullName) }