Class KubeMaster : KubeNode {
  KubeMaster(
    [String]$Hostname,
    [String]$DomainName,
    [String]$RootFolder,
    [String]$IPAddress,
    [String]$ClusterDns
  ) : base($Hostname, $DomainName, $RootFolder, $IPAddress) {
    $this::ClusterDns = $ClusterDns
    $this::ClusterHostnames += $Hostname
    $this::ClusterIPs += $IPAddress
    $this::ClusterMembers[$Hostname] = $IPAddress

    $this.NewEtcdCa()
    $this.NewEtcdServerPeerCert()
  }
  static [String]$EtcdCACert
  static [String]$EtcdCAKey
  static [String]$EtcdClientCert
  static [String]$EtcdClientKey
  [String]$EtcdServerCert
  [String]$EtcdServerKey
  [String]$EtcdPeerCert
  [String]$EtcdPeerKey
  static [String]$ClusterDns
  static [Array]$ClusterIPs = @()
  static [Array]$ClusterHostnames = @()
  static [Hashtable]$ClusterMembers = @{}

  [String] UserData() {
    $WriteFiles = [ordered]@{
      "/etc/kubernetes/pki/etcd/ca.pem"         = $this::EtcdCACert
      "/etc/kubernetes/pki/etcd/ca-key.pem"     = $this::EtcdCAKey
      "/etc/kubernetes/pki/etcd/client.pem"     = $this::EtcdClientCert
      "/etc/kubernetes/pki/etcd/client-key.pem" = $this::EtcdClientKey
      "/etc/kubernetes/pki/etcd/server.pem"     = $this.EtcdServerCert
      "/etc/kubernetes/pki/etcd/server-key.pem" = $this.EtcdServerKey
      "/etc/kubernetes/pki/etcd/peer.pem"       = $this.EtcdPeerCert
      "/etc/kubernetes/pki/etcd/peer-key.pem"   = $this.EtcdPeerKey
      "/tmp/etcd.service"                       = $this.EtcdService()
      "/etc/kubernetes/kubeadm.yaml"            = $this.KubeAdm()
    }
    $RunCmd = @(
      "apt-get update",
      "apt-get install -y linux-virtual-lts-xenial",
      "apt-get install -y `"linux-cloud-tools-`$(uname -r)`"",
      "apt-get install -y docker.io",
      "apt-get install -y apt-transport-https",
      "curl -sSL https://github.com/coreos/etcd/releases/download/v3.2.18/etcd-v3.2.18-linux-amd64.tar.gz | tar -xzv --strip-components=1 -C /usr/local/bin/",
      "rm -rf etcd-v3.2.18-linux-amd64*",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -",
      "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list",
      "deb http://apt.kubernetes.io/ kubernetes-xenial main",
      "EOF",
      "apt-get update",
      "apt-get install -y kubelet kubeadm kubectl",
      "sed -i '0,/ExecStart=/s/ExecStart=/Environment=`"KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs`"\n&/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",
      "mkdir /var/lib/etcd",
      "mv /tmp/etcd.service /etc/systemd/system/",
      "systemctl daemon-reload",
      "systemctl enable etcd",
      "sysctl net.bridge.bridge-nf-call-iptables=1"
    )
    $params = @{
      "BootCmd"    = @("hostname $($this.Hostname)")
      "WriteFiles" = $WriteFiles
      "RunCmd"     = $RunCmd
      "Users"      = [ordered]@{ $this.SshUser = $this.SshPublicKey }
      "Reboot"     = $true
    }
    return Get-UserDataYaml @params
  }

  [String] KubeAdm() {
    return @"
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: $($this.IPAddress)
etcd:
  endpoints: $($this::ClusterIPs.Foreach({ "`n    - https://${_}:2379" }))
  caFile: /etc/kubernetes/pki/etcd/ca.pem
  certFile: /etc/kubernetes/pki/etcd/client.pem
  keyFile: /etc/kubernetes/pki/etcd/client-key.pem
networking:
  podSubnet: 10.244.0.0/16
apiServerCertSANs:
  - $($this::ClusterDns)
apiServerExtraArgs:
  apiserver-count: '3'
"@ -replace "`r`n", "`n"
  }
  [String] EtcdService() {
    $etcdcluster = @()
    $this::ClusterMembers.GetEnumerator().Foreach( {
        $etcdcluster += "$($_.Key)=https://$($_.Value):2380"
      })
    $initialcluster = $etcdcluster -join ","
    return @"
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd

[Service]
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/bin/etcd --name $($this.Hostname) \
    --data-dir /var/lib/etcd \
    --listen-client-urls https://$($this.IPAddress):2379 \
    --advertise-client-urls https://$($this.IPAddress):2379 \
    --listen-peer-urls https://$($this.IPAddress):2380 \
    --initial-advertise-peer-urls https://$($this.IPAddress):2380 \
    --cert-file=/etc/kubernetes/pki/etcd/server.pem \
    --key-file=/etc/kubernetes/pki/etcd/server-key.pem \
    --client-cert-auth \
    --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --peer-cert-file=/etc/kubernetes/pki/etcd/peer.pem \
    --peer-key-file=/etc/kubernetes/pki/etcd/peer-key.pem \
    --peer-client-cert-auth \
    --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --initial-cluster ${initialcluster} \
    --initial-cluster-token my-etcd-token \
    --initial-cluster-state new

[Install]
WantedBy=multi-user.target
"@ -replace "`r`n", "`n"
  }

  [Void] NewEtcdCa() {
    if ([String]::IsNullOrEmpty($this::EtcdCACert)) {
      $ca = New-CfsslCa -Directory $this.WorkingDir
      $this::EtcdCACert = $ca.cert
      $this::EtcdCAKey = $ca.key
    }
    else {
      $this.WriteFile("ca.pem", $this::EtcdCACert)
      $this.WriteFile("ca-key.pem", $this::EtcdCAKey)
    }
    if ([String]::IsNullOrEmpty($this::EtcdClientCert)) {
      $clientcsr = @"
{
  "CN": "client",
  "key": {
    "algo": "ecdsa",
    "size": 256
  }
}
"@ -replace "`r`n", "`n"
      $clientjson = $this.WriteFile("client.json", $clientcsr)
      $cert = New-CfsslCert -Directory $this.WorkingDir -ProfileName "client" -CsrJson $clientjson
      $this::EtcdClientCert = $cert.cert
      $this::EtcdClientKey = $cert.key
    }
    else {
      $this.WriteFile("client.pem", $this::EtcdClientCert)
      $this.WriteFile("client-key.pem", $this::EtcdClientKey)
    }
  }

  [Void] NewEtcdServerPeerCert() {
    $configjson = @{
      "CN"    = $this.Hostname
      "hosts" = @(
        $this.Hostname,
        $this.IPAddress
      )
      "key"   = @{
        "algo" = "ecdsa"
        "size" = 256
      }
    } | ConvertTo-Json
    if ([String]::IsNullOrEmpty($this.EtcdServerCert)) {
      $servercsr = $this.WriteFile("server.json", $configjson)
      $cert = New-CfsslCert -Directory $this.WorkingDir -ProfileName "server" -CsrJson $servercsr
      $this.EtcdServerCert = $cert.cert
      $this.EtcdServerKey = $cert.key
    }
    else {
      $this.WriteFile("server.pem", $this.EtcdServerCert)
      $this.WriteFile("server-key.pem", $this.EtcdServerKey)
    }
    if ([String]::IsNullOrEmpty($this.EtcdPeerCert)) {
      $servercsr = $this.WriteFile("peer.json", $configjson)
      $cert = New-CfsslCert -Directory $this.WorkingDir -ProfileName "peer" -CsrJson $servercsr
      $this.EtcdPeerCert = $cert.cert
      $this.EtcdPeerKey = $cert.key
    }
    else {
      $this.WriteFile("peer.pem", $this.EtcdPeerCert)
      $this.WriteFile("peer-key.pem", $this.EtcdPeerKey)
    }
  }

  [String] CreateIso($Oscdimg) {
    $outpath = Join-Path $this.WorkingDir "iso"
    if (-not(Test-Path $outpath)) {
      $null = New-Item -Path $outpath -ItemType Directory
    }
    else {
      Get-ChildItem $outpath | Remove-Item -Force
    }
    $this.WriteFile("iso\meta-data", $this.MetaData())
    $this.WriteFile("iso\user-data", $this.UserData())
    $this.WriteFile("iso\network-config", $this.NetworkConfig())
    $iso = Join-Path $outpath "cidata.iso"
    Start-ProcessWithOutput -FilePath $Oscdimg -Arguments "$outpath $iso -j2 -lcidata"
    return $iso
  }
}