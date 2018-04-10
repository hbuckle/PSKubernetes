function New-CfsslCert {
  param (
    [String]$Directory,
    [String]$ProfileName,
    [String]$CsrJson
  )
  $capem = Join-Path $Directory "ca.pem" -Resolve
  $cakey = Join-Path $Directory "ca-key.pem" -Resolve
  $certpem = Join-Path $Directory "${ProfileName}.pem"
  $certkey = Join-Path $Directory "${ProfileName}-key.pem"
  $cert = & $Script:cfssl -loglevel "5" gencert -ca="$capem" -ca-key="$cakey" -config="$($Script:caconfig)" -profile="$ProfileName" "$CsrJson" | 
    ConvertFrom-Json
  $cert.cert | Out-File $certpem -Encoding ascii
  $cert.key | Out-File $certkey -Encoding ascii
  return $cert
}