# PSKubernetes

Module to bootstrap virtualized Kubernetes clusters in a Windows environment.

## Requirements

### Infrastructure

* A Hyper-V host. The host will need enough resources to run the virtual machines.
A master node uses approximately 2.5GB of memory. The host needs internet access
to download pre-requisites and the Kubernetes components.

* A Windows DHCP server. A reservation will be created for each node.

* A Windows DNS server.

* The module assumes everything is joined to a domain and you are running as
a user with admin permissions over the Hyper-V, DHCP and DNS servers.

### Tools

* `oscdimg.exe` - 