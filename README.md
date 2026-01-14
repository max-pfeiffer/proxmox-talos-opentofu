# proxmox-talos-opentofu
A turnkey Kubernetes cluster built with [Talos Linux](https://www.talos.dev/) running on a
[Proxmox VE hypervisor](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).
Provisioning is done with [OpenTofu](https://opentofu.org/).

Kubernetes cluster features:
* Talos Linux v1.11.6
* Kubernetes v1.34.2
* no kube-proxy
* [Cilium v1.18.3](https://cilium.io/) as Container Network Interface (CNI) 
  * without kube-proxy
  * with [L2 loadbalancer support](https://docs.cilium.io/en/stable/network/l2-announcements/)
  * with [Ingress controller support](https://docs.cilium.io/en/stable/network/servicemesh/ingress/)
  * with [Gateway API support](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
  * with [Egress gateway support](https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway/)
* [Gateway API v1.3.0](https://gateway-api.sigs.k8s.io/) CRDs are installed 

This Kubernetes cluster is meant to be used in a test or home lab environment.

## Requirements
You need to have installed on your local machine:
* [OpenTofu](https://opentofu.org/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) (for testing and cluster interaction)

## Provisioning
The project is grouped in three sections:
* proxmox: provisioning of virtual machines, operating systems and Kubernetes cluster
* kubernetes: provisioning of Kubernetes cluster resources
* argocd: provisioning of Kubernetes resources using GitOps, can be installed with `install_argocd_app_of_apps` flag 

This way you can choose to only provision the cluster itself or/and provision Kubernetes resources and bootstrap
also [ArgoCD](https://argoproj.github.io/cd/).

You will have an [ArgoCD](https://argoproj.github.io/cd/) instance running in the cluster eventually. You can then
install your applications using the GitOps approach. Have a look at `install_argocd_app_of_apps` and the related
configuration variables for further options.

The main idea is to configure the Kubernetes cluster and also the [ArgoCD](https://argoproj.github.io/cd/) bootstrap with infrastructure as code
using [OpenTofu](https://opentofu.org/). So it can be rolled out very quickly and consistently. All other Kubernetes resources are then
provisioned using a git repository via the GitOps approach.

Usually you want to keep your cluster infrastructure and [ArgoCD](https://argoproj.github.io/cd/) bootstrap separate from your Kubernetes resources.
That way you have everything decoupled and migrate to a new cluster infrastructure more easily. I added the `argocd`
directory mainly for demonstration purposes.

### Proxmox VE
First step is to provision the Proxmox part: create a `configuration.auto.tfvars` file based on the example and
edit it so it suits your needs:
```shell
$ cd proxmox
$ cp configuration.auto.tfvars.example configuration.auto.tfvars
$ vim configuration.auto.tfvars
```
Then apply the configuration using OpenTofu:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```
You can then grab and move the kube config file for Kubernetes provisioning like so:
```shell
$ tofu output kubeconfig -raw > ~/.kube/config
$ chmod 600 ~/.kube/config
```
Test if your cluster access works by listing the nodes:
```shell
$ kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
your-cp-0       Ready    control-plane   5d    v1.34.2
your-worker-0   Ready    <none>          5d    v1.34.2
```
You might need to wait a bit until the nodes come up. Proceed with the next step when all nodes are in the `Ready`
state.

### Kubernetes
Secondly, you can provision the resources inside the Kubernetes cluster. You have a couple of options to choose 
from. All options can be configured using variables in `configuration.auto.tfvars`:
1. **Quick start**: installs Cilium LB config, ArgoCD, Ingress without TLS (default settings) with OpenTofu. [ArgoCD](https://argoproj.github.io/cd/) is
   available on http://argocd.local.
   * install_cilium_lb_config = true
   * argocd_domain = "argocd.local"
   * argocd_server_insecure = true
   * argocd_ingress_enabled = true
   * install_argocd_app_of_apps = false
   * install_argocd_app_of_apps_git_repo_secret = false
2. **GitOps using your own repository**: installs ArgoCD, no Cilium LB config, no Ingress and the Kubernetes resources in
   the repository you specify in `argocd_app_of_apps_source`. Credentials for a private repository can be configured
   and installed with OpenTofu using `install_argocd_app_of_apps_git_repo_secret` and the related variables:
   * install_cilium_lb_config = false
   * argocd_domain = "yourpublicdomain.com"
   * argocd_server_insecure = true
   * argocd_ingress_enabled = false
   * install_argocd_app_of_apps = true
   * argocd_app_of_apps_source = YOUR SOURCE SETTINGS
   * install_argocd_app_of_apps_git_repo_secret = true
   * argocd_app_of_apps_git_repo_secret_url = "https://github.com/you/yourrepo.git"
   * argocd_app_of_apps_git_repo_secret_password_or_token = "github_pat_OLImf09435459hfjoi9m435298524jtfjn45i8tmnmds329023jdhn"

These are two use cases I envision here. Please regard them as examples. Of course, you can combine the variables to
any other setup which suits your needs.

For doing a **GitOps quick start** you can fork this repository and point the `argocd_app_of_apps_source` to the 
`argocd` directory of your newly forked repository. This way you can make use of the example Kubernetes resources in
`argocd` directory and edit them to match your infrastructure. 

Create a `configuration.auto.tfvars` like so and edit it to your liking:
```shell
$ cd kubernetes
$ cp configuration.auto.tfvars.example configuration.auto.tfvars
$ vim configuration.auto.tfvars
```
Then do the provisioning with OpenTofu:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```
You can grab the [ArgoCD](https://argoproj.github.io/cd/) initial admin password with `kubectl` afterwards:
```shell
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## Roadmap
Proxmox part:
* make node resources configurable (CPU, memory, etc.)
* make version upgrades possible for Kubernetes Nodes with OpenTofu

GitOps part:
* add more storage options i.e. Ceph, local
* add Keycloak operator and Keycloak instance for SSO
* add Prometheus/Grafana for monitoring
* add Alloy/Loki for logging
* add Velero for disaster recovery

I am happy to receive pull requests for any improvements.

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* [Cilium documentation](https://docs.cilium.io/en/stable/)
* [Gateway API](https://gateway-api.sigs.k8s.io/)
* Terraform providers:
  * [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
  * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
  * [terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes) 
  * [terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm)
* Helm charts:
  * [ArgoCD](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
  * [Cilium](https://artifacthub.io/packages/helm/cilium/cilium)