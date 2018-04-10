Class KubeNode {

  KubeNode(
    [String]$Hostname,
    [String]$DomainName,
    [String]$RootFolder,
    [String]$IPAddress
  ) {
    $this.InstanceID = (New-Guid).Guid
    $this.IPAddress = $IPAddress
    $this.Hostname = $Hostname
    $this.VMName = $Hostname
    $this.DomainName = $DomainName
    $this.FQDN = "${Hostname}.${DomainName}"
    $this.MacAddress = [KubeNode]::NewMacAddress("")

    if (-not(Test-Path $RootFolder)) {
      $null = New-Item $RootFolder -ItemType Directory
    }
    $this.WorkingDir = (Join-Path $RootFolder $this.InstanceID)
    if (-not(Test-Path $this.WorkingDir)) {
      $null = New-Item $this.WorkingDir -ItemType Directory
      # TODO Set ACL
    }
    $this.CreateSshKey()
  }

  [String]$InstanceID
  [String]$Hostname
  [String]$DomainName
  [String]$FQDN
  [String]$VMName
  [String]$MacAddress
  [String]$IPAddress
  [String]$WorkingDir
  [String]$SshUser
  [String]$SshPrivateKey
  [String]$SshPublicKey

  [String] NetworkConfig() {
    return @"
version: 1
config:
  - type: physical
    name: eth0
    subnets:
      - type: dhcp
"@ -replace "`r`n", "`n"
  }

  [String] MetaData() {
    return @"
instance-id: $($this.InstanceID)
local-hostname: $($this.Hostname)
"@ -replace "`r`n", "`n"
  }

  [String] UserData() {
    return Get-UserDataYaml -BootCmd @("hostname $($this.Hostname)")
  }

  static [String] NewMacAddress([String]$Separator) {
    return [String]::Join($Separator, @(
        "02",
        ("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
        ("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
        ("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
        ("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
        ("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255))
      ))
  }

  [Void] CreateSshKey() {
    $keypath = Join-Path $this.WorkingDir "id_rsa"
    if (-not(Test-Path $keypath)) {
      Start-ProcessWithOutput -FilePath "ssh-keygen.exe" -Arguments "-f ${keypath} -t rsa -N """" -q -C psuser"
    }
    $this.SshPrivateKey = Get-Content $keypath -Raw
    $this.SshPublicKey = Get-Content "$keypath.pub" -Raw
    $this.SshUser = "psuser"
  }

  [String] InvokeSshCommand([String]$Command) {
    $privatekey = Join-Path $this.WorkingDir "id_rsa"
    $result = (& ssh.exe -o "LogLevel=error" `
        -o "UserKnownHostsFile=NUL" `
        -o "StrictHostKeyChecking=no" `
        "$($this.SshUser)@$($this.IPAddress)" `
        -i $privatekey `
        "$Command") -join "`n"
    return $result
  }

  [String] WriteFile([String]$Name, [String]$Content) {
    $encoding = [Text.UTF8Encoding]::new($false)
    $path = Join-Path $this.WorkingDir $Name
    [System.IO.File]::WriteAllLines($path, $Content, $encoding)
    return $path
  }
}