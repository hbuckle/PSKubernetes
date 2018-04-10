function Install-KubeControlPlane {
  [CmdletBinding()]
  param (
    [KubeMaster]$Master
  )
  Write-Information "Installing Kubernetes control plane: $($Master.Hostname)"
  $initresult = $Master.InvokeSshCommand("sudo kubeadm init --config=/etc/kubernetes/kubeadm.yaml 2>&1")
  if ($initresult -match "error") {
    throw $initresult
  }
  Write-Verbose $initresult
}