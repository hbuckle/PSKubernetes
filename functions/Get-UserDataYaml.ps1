function Get-UserDataYaml {
  [CmdletBinding()]
  param (
    [String[]]$BootCmd = @(),
    [System.Collections.Specialized.OrderedDictionary]$WriteFiles = [ordered]@{},
    [String[]]$RunCmd = @(),
    [System.Collections.Specialized.OrderedDictionary]$Users = [ordered]@{},
    [Bool]$Reboot = $false
  )
  $output = "#cloud-config`n"

  if ($BootCmd.Count -gt 0) {
    $bootcmdyaml = @{ "bootcmd" = $BootCmd }
    $output += $bootcmdyaml | ConvertTo-Yaml
  }

  if ($WriteFiles.Count -gt 0) {
    $writefilesyaml = @{ "write_files" = @() }
    foreach ($file in $WriteFiles.GetEnumerator()) {
      $writefilesyaml["write_files"] += [ordered]@{
        "content"     = "$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($file.Value)))"
        "encoding"    = "b64"
        "owner"       = "root:root"
        "path"        = "$($file.Key)"
        "permissions" = "'0644'"
      }
    }
    $output += $writefilesyaml | ConvertTo-Yaml
  }

  if ($RunCmd.Count -gt 0) {
    $runcmdyaml = @{ "runcmd" = $RunCmd }
    $output += $runcmdyaml | ConvertTo-Yaml
  }

  if ($Users.Count -gt 0) {
    $usersyaml = @{ "users" = @() }
    foreach ($user in $Users.GetEnumerator()) {
      $usersyaml["users"] += [ordered]@{
        "name"                = "$($user.Key)"
        "sudo"                = "ALL=(ALL) NOPASSWD:ALL"
        "groups"              = "users, admin"
        "lock_passwd"         = "true"
        "ssh-authorized-keys" = @( $user.Value )
      }
    }
    $output += $usersyaml | ConvertTo-Yaml
  }

  if ($Reboot) {
    $output += @{ "power_state" = [ordered]@{
        "mode"      = "reboot"
        "timeout"   = 30
        "condition" = "True"
      }
    } | ConvertTo-Yaml
  }

  return $output -replace "`r`n", "`n"
}