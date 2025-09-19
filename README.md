# proxmox-talos-opentofu
A turnkey Kubernetes cluster built with [Talos Linux](https://www.talos.dev/) running on a
[Proxmox VE hypervisor](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).
Provisioning is done with [OpenTofu](https://opentofu.org/).

The Kubernetes cluster uses [Cilium](https://cilium.io/) as Container Network Interface (CNI).

## Requirements
You need to have installed on your local machine:
* [OpenTofu](https://opentofu.org/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) (for testing and cluster interaction)

## Provisioning
The project is grouped in two sections:
* proxmox: provisioning of virtual machines, operating systems and Kubernetes cluster
* kubernetes: provisioning of Kubernetes cluster resources

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

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* Terraform providers:
  * [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
  * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
  * [terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm)
* Helm charts:
  * [ArgoCD](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)