. "..\classes\KubeNode.ps1"
Get-Module "PSKubernetes" | Remove-Module -Force
Describe "KubeNode" {
  Mock "New-Guid" { return [PSObject]@{Guid = "kubenode"} }
  function Start-ProcessWithOutput {
    "private" | Out-File "${TestDrive}\kubenode\id_rsa" -NoNewline
    "public" | Out-File "${TestDrive}\kubenode\id_rsa.pub" -NoNewline
  }
  Context "Static Methods" {
    Describe "NewMacAddress" {
      It "Returns a valid MAC address" {
        [KubeNode]::NewMacAddress("-") | Should -Match -RegularExpression '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
      }
    }
  }
  Context "Methods" {
    Describe "WriteFile" {
      It "Writes a file to the working directory" {
        $kubenode = [KubeNode]::new("host", "domain", $TestDrive, "ip")
        $kubenode.WriteFile("test.txt", "content")
        Get-Content "${TestDrive}\kubenode\test.txt" | Should -BeExactly "content"
      }
    }
  }
  Context "Properties" {
    Context "On creation" {
      It "Sets all instance properties" {
        $kubenode = [KubeNode]::new("host", "domain", $TestDrive, "ip")
        $kubenode.InstanceID | Should -BeExactly "kubenode"
        $kubenode.Hostname | Should -BeExactly "host"
        $kubenode.DomainName | Should -BeExactly "domain"
        $kubenode.FQDN | Should -BeExactly "host.domain"
        $kubenode.VMName | Should -BeExactly "host"
        $kubenode.MacAddress | Should -Not -BeNullOrEmpty
        $kubenode.IPAddress | Should -BeExactly "ip"
        $kubenode.WorkingDir | Should -BeExactly "${TestDrive}\kubenode"
        $kubenode.SshUser | Should -BeExactly "psuser"
        $kubenode.SshPrivateKey | Should -BeExactly "private"
        $kubenode.SshPublicKey | Should -BeExactly "public"
      }
    }
  }
}