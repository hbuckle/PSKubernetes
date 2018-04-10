function Convert-CloudImg {
  [CmdletBinding()]
  param (
    [String]$CloudImgPath,
    [String]$HyperVHost
  )
  $vhdx = Invoke-Command -ScriptBlock {
    param ($CloudImgPath)
    $folder = Split-Path $CloudImgPath -Parent
    $qemuzip = Join-Path $folder "qemuimg.zip"
    if (-not(Test-Path $qemuzip)) {
      Invoke-WebRequest -Uri "https://cloudbase.it/downloads/qemu-img-win-x64-2_3_0.zip" -UseBasicParsing -OutFile $qemuzip
      Expand-Archive $qemuzip -DestinationPath "$folder\qemuimg"
    }
    $img = Get-Item $CloudImgPath
    $name = $img.BaseName
    $vhdx = Join-Path $img.Directory.FullName "$name.vhdx"
    if (-not(Test-Path $vhdx)) {
      & "$folder\qemuimg\qemu-img.exe" convert -f qcow2 $CloudImgPath -O vhdx -o subformat=dynamic $vhdx
    }
    Write-Output $vhdx
  } -ComputerName $HyperVHost -ArgumentList $CloudImgPath
  Write-Information "Base VHDX: $vhdx"
  return $vhdx
}