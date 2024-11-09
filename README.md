# proxmox-talos-opentofu
Proof of concept project using [OpenTofu](https://opentofu.org/) to install a Kubernetes cluster on a Proxmox
hypervisor using [Talos Linux](https://www.talos.dev/).

## Requirements
You need to have installed on your local machine:
* [OpenTofu](https://opentofu.org/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) (for testing and cluster interaction)

## Provisioning
The project is grouped in two modules:
* proxmox: provisioning of virtual machines, operating systems and Kubernetes cluster
* kubernetes: provisioning of Kubernetes cluster resources

So you want first to provision the Proxmox part: create a `credentials.auto.tfvars` file based on the example.
```shell
cd proxmox
tofu init
tofu plan
tofu apply
```

You can then grab the kube config file for Kubernetes provisioning like so:
```shell
tofu output kubeconfig
```
and put its contents into your `~/.kube/config`.

Test if your cluster access works by listing the nodes:
```shell
kubectl get nodes
```

Secondly, you can provision the Resources inside the Kubernetes cluster:
```shell
cd kubernetes
tofu init
tofu plan
tofu apply
```

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* Terraform providers/modules
  * [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
  * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
