Import-Module "$(Split-Path $PSScriptRoot -Parent)\pskubernetes.psd1" -Force
InModuleScope "PSKubernetes" {
  Describe "Get-UserDataYaml" {
    Context "Without parameters" {
      It "Returns an empty user-data yaml string" {
        $expected = @"
#cloud-config

"@ -replace "`r`n", "`n"
        Get-UserDataYaml | Should -BeExactly $expected
      }
    }
    Context "With parameters" {
      It "Returns a valid user-data yaml string" {
        $params = @{
          BootCmd    = @(
            "bootcmd1",
            "bootcmd2",
            "bootcmd3"
          )
          WriteFiles = [ordered]@{
            "path1" = "content1"
            "path2" = "content2"
          }
          RunCmd     = @(
            "cmd1",
            "cmd2",
            "cmd3"
          )
          Users      = [ordered]@{
            "user1" = "key1"
            "user2" = "key2"
          }
        }
        $expected = @"
#cloud-config
bootcmd:
- bootcmd1
- bootcmd2
- bootcmd3
write_files:
- content: Y29udGVudDE=
  encoding: b64
  owner: root:root
  path: path1
  permissions: '0644'
- content: Y29udGVudDI=
  encoding: b64
  owner: root:root
  path: path2
  permissions: '0644'
runcmd:
- cmd1
- cmd2
- cmd3
users:
- name: user1
  sudo: ALL=(ALL) NOPASSWD:ALL
  groups: users, admin
  lock_passwd: true
  ssh-authorized-keys:
  - key1
- name: user2
  sudo: ALL=(ALL) NOPASSWD:ALL
  groups: users, admin
  lock_passwd: true
  ssh-authorized-keys:
  - key2

"@ -replace "`r`n", "`n"
        Get-UserDataYaml @params | Should -BeExactly $expected
      }
      It "Returns a valid user-data yaml string with reboot" {
        $params = @{
          BootCmd = @(
            "bootcmd1",
            "bootcmd2",
            "bootcmd3"
          )
          Reboot  = $true
        }
        $expected = @"
#cloud-config
bootcmd:
- bootcmd1
- bootcmd2
- bootcmd3
power_state:
  mode: reboot
  timeout: 30
  condition: True

"@ -replace "`r`n", "`n"
        Get-UserDataYaml @params | Should -BeExactly $expected
      }
    }
  }
}