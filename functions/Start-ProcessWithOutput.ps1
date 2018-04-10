function Start-ProcessWithOutput {
  [CmdletBinding()]
  param (
    [String]$FilePath,
    [String]$Arguments
  )
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName               = $FilePath
  $pinfo.RedirectStandardError  = $true
  $pinfo.RedirectStandardOutput = $true
  $pinfo.UseShellExecute        = $false
  $pinfo.Arguments              = $Arguments
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  $null = $p.Start()
  $p.WaitForExit()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  if ($p.ExitCode -ne 0) {
    $errormessage = $stderr + "`n" + $stdout
    throw $errormessage
  }
  else {
    Write-Output $stdout
  }
}