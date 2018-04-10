function Install-KubeCni {
  [CmdletBinding()]
  param (
    [KubeMaster]$Master,
    [String]$CniConfigUrl = "https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml"
  )
  Write-Information "Installing ${CniConfigUrl} on $($Master.Hostname)"
  $cniresult = $Master.InvokeSshCommand("sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f ${CniConfigUrl}")
  Write-Verbose $cniresult
}