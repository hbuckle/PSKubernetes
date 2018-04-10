. "..\classes\KubeNode.ps1"
. "..\classes\KubeMaster.ps1"
Get-Module "PSKubernetes" | Remove-Module -Force
Describe "KubeMaster" {
  Mock "New-Guid" { return [PSObject]@{Guid = "kubemaster"} }
  function Start-ProcessWithOutput {
    "private" | Out-File "${TestDrive}\kubemaster\id_rsa" -NoNewline
    "public" | Out-File "${TestDrive}\kubemaster\id_rsa.pub" -NoNewline
  }
  function New-CfsslCa {
    return @{
      "cert" = "cert"
      "key"  = "key"
    }
  }
  function New-CfsslCert {
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
        "TestDrive:\kubemaster\server.pem"     | Remove-Item -Force
        "TestDrive:\kubemaster\server-key.pem" | Remove-Item -Force
        "TestDrive:\kubemaster\peer.pem"       | Remove-Item -Force
        "TestDrive:\kubemaster\peer-key.pem"   | Remove-Item -Force
        $kubemaster.NewEtcdServerPeerCert()
        "TestDrive:\kubemaster\server.pem"     | Should -FileContentMatchExactly "cert"
        "TestDrive:\kubemaster\server-key.pem" | Should -FileContentMatchExactly "key"
        "TestDrive:\kubemaster\peer.pem"       | Should -FileContentMatchExactly "cert"
        "TestDrive:\kubemaster\peer-key.pem"   | Should -FileContentMatchExactly "key"
      }
    }
  }
}