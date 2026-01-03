# proxmox-talos-opentofu
A turnkey Kubernetes cluster built with [Talos Linux](https://www.talos.dev/) running on a
[Proxmox VE hypervisor](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).
Provisioning is done with [OpenTofu](https://opentofu.org/).

Kubernetes cluster features:
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
The project is grouped in two sections:
* proxmox: provisioning of virtual machines, operating systems and Kubernetes cluster
* kubernetes: provisioning of Kubernetes cluster resources

This way you can choose to only provision the cluster itself or/and provision Kubernetes resources and bootstrap
also [ArgoCD](https://argoproj.github.io/cd/).

You will have an [ArgoCD](https://argoproj.github.io/cd/) instance running in the cluster eventually. You can then
install your applications using the GitOps approach. 

### Proxmox VE
So you want first to provision the Proxmox part: create a `configuration.auto.tfvars` file based on the example and
edit it so it suits your needs:
```shell
cd proxmox
cope configuration.auto.tfvars.example configuration.auto.tfvars
vim configuration.auto.tfvars
```
Then apply the configuration using OpenTofu:
```shell
tofu init
tofu plan
tofu apply
```
You can then grab and move the kube config file for Kubernetes provisioning like so:
```shell
tofu output kubeconfig -raw > ~/.kube/config
chmod 600 ~/.kube/config
```
Test if your cluster access works by listing the nodes:
```shell
kubectl get nodes
```
You might need to wait a bit until the cluster comes up. Proceed with the next step when all nodes are in the `ready`
state.

### Kubernetes
Secondly, you can provision the Resources inside the Kubernetes cluster. Currently, this project just installs
ArgoCD in the `argocd` namespace in the cluster. You can then add on top of this by adding your own resources 
using the GitOps approach.
You need to create a `configuration.auto.tfvars` file as well first:
```shell
cd kubernetes
cope configuration.auto.tfvars.example configuration.auto.tfvars
vim configuration.auto.tfvars
```
Then do the provisiong with OpenTofu:
```shell
tofu init
tofu plan
tofu apply
```
The [ArgoCD](https://argoproj.github.io/cd/) instance should be available under the `argocd_domain` you configured
in your `configuration.auto.tfvars` file i.e., http://argocd.local.

## Roadmap
My todo list for the GitOps part:
* bootstrap a certificate authority
* add storage options i. e. NFS, Ceph, local
* add Keycloak operator and Keycloak instance for SSO
* add Prometheus/Grafana for monitoring
* add Alloy/Loki for logging
* add Velero for disaster recovery

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* [Cilium documentation](https://docs.cilium.io/en/stable/)
* [Gateway API](https://gateway-api.sigs.k8s.io/)
* Terraform providers:
  * [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
  * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
  * [terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm)
* Helm charts:
  * [ArgoCD](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
  * [Cilium](https://artifacthub.io/packages/helm/cilium/cilium)