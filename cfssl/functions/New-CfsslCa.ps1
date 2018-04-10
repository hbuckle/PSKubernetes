function New-CfsslCa {
  param (
    [String]$Directory
  )
  $capem = Join-Path $Directory "ca.pem"
  $cakey = Join-Path $Directory "ca-key.pem"
  $ca = & $Script:cfssl -loglevel "5" gencert -initca "$($Script:cacsr)" | ConvertFrom-Json
  $ca.cert | Out-File $capem -Encoding ascii
  $ca.key | Out-File $cakey -Encoding ascii
  return $ca
}