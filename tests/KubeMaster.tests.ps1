Import-Module "$(Split-Path $PSScriptRoot -Parent)\pskubernetes.psd1" -Force
InModuleScope "PSKubernetes" {
  Describe "KubeMaster" {
    $guid = "kubemaster"
    BeforeEach {
      if (Test-Path "TestDrive:\${guid}") {
        Remove-Item "TestDrive:\${guid}" -Recurse -Force
      }
    }
    Mock "New-Guid" { return [PSObject]@{Guid = $guid } }
    Mock "Start-ProcessWithOutput" -ParameterFilter { $FilePath -match "ssh-keygen.exe" } {
      "private" | Out-File "${TestDrive}\${guid}\id_rsa" -NoNewline
      "public" | Out-File "${TestDrive}\${guid}\id_rsa.pub" -NoNewline
    }
    Mock "New-CfsslCa" {
      "cert" | Out-File "${TestDrive}\${guid}\ca.pem" -NoNewline
      "key" | Out-File "${TestDrive}\${guid}\ca-key.pem" -NoNewline
      return @{
        "cert" = "cert"
        "key"  = "key"
      }
    }
    Mock "New-CfsslCert" {
      "cert" | Out-File "${TestDrive}\${guid}\${ProfileName}.pem" -NoNewline
      "key" | Out-File "${TestDrive}\${guid}\${ProfileName}-key.pem" -NoNewline
      return @{
        "cert" = "cert"
        "key"  = "key"
      }
    }
    Context "Methods" {
      Describe "NewEtcdServerPeerCert" {
        It "Sets Server and Peer cert properties" {
          $kubemaster = [KubeMaster]::new("host", "domain", $TestDrive, "ip", "apiserver")
          $kubemaster.EtcdServerCert = $null
          $kubemaster.EtcdServerKey  = $null
          $kubemaster.EtcdPeerCert   = $null
          $kubemaster.EtcdPeerKey    = $null
          $kubemaster.NewEtcdServerPeerCert()
          $kubemaster.EtcdServerCert | Should -BeExactly "cert"
          $kubemaster.EtcdServerKey  | Should -BeExactly "key"
          $kubemaster.EtcdPeerCert   | Should -BeExactly "cert"
          $kubemaster.EtcdPeerKey    | Should -BeExactly "key"
        }
        It "Writes Server and Peer cert files" {
          $kubemaster = [KubeMaster]::new("host", "domain", $TestDrive, "ip", "apiserver")
          "TestDrive:\${guid}\server.pem"     | Remove-Item -Force
          "TestDrive:\${guid}\server-key.pem" | Remove-Item -Force
          "TestDrive:\${guid}\peer.pem"       | Remove-Item -Force
          "TestDrive:\${guid}\peer-key.pem"   | Remove-Item -Force
          $kubemaster.NewEtcdServerPeerCert()
          "TestDrive:\${guid}\server.pem"     | Should -FileContentMatchExactly "cert"
          "TestDrive:\${guid}\server-key.pem" | Should -FileContentMatchExactly "key"
          "TestDrive:\${guid}\peer.pem"       | Should -FileContentMatchExactly "cert"
          "TestDrive:\${guid}\peer-key.pem"   | Should -FileContentMatchExactly "key"
        }
      }
      Describe "CreateIso" {
        It "Creates cidata.iso" {
          $kubemaster = [KubeMaster]::new("host", "domain", $TestDrive, "ip", "apiserver")
          $iso = $kubemaster.CreateIso()
          $iso | Should -Exist
        }
      }
    }
  }
}