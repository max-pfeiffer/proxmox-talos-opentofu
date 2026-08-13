# Proxmox Talos OpenTofu - Turnkey Kubernetes Cluster
A turnkey Kubernetes cluster built with [Talos Linux](https://www.talos.dev/) running on a
[Proxmox VE hypervisor](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).
Provisioning is done with [OpenTofu](https://opentofu.org/).

Kubernetes cluster features:
* [Talos Linux v1.13.8](https://www.talos.dev/) 
* Kubernetes v1.36.3
* no kube-proxy
* [Cilium v1.18.3](https://cilium.io/) as Container Network Interface (CNI) 
  * without kube-proxy
  * with [L2 loadbalancer support](https://docs.cilium.io/en/stable/network/l2-announcements/)
  * with [Ingress controller support](https://docs.cilium.io/en/stable/network/servicemesh/ingress/)
  * with [Gateway API support](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
  * with [Egress gateway support](https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway/)
* [Gateway API v1.3.0](https://gateway-api.sigs.k8s.io/) CRDs are installed 
* [ArgoCD v3.4.2](https://argoproj.github.io/cd/)

This Kubernetes cluster is meant to be used in a test or home lab environment.

## Requirements
You need to have installed on your local machine:
* [OpenTofu](https://opentofu.org/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) (for testing and cluster interaction)

## Provisioning
The project is grouped into three sections:
* proxmox: provisioning of virtual machines, operating system and Kubernetes cluster
* kubernetes: provisioning of Kubernetes resources in the running Kubernetes cluster
* argocd: provisioning of Kubernetes resources using GitOps approach, can be configured with `install_argocd_app_of_apps` flag 

This way you can choose to only provision the cluster itself. As an additional option you can provision Kubernetes
resources and bootstrap also [ArgoCD](https://argoproj.github.io/cd/).

Going through all the steps, you will have an [ArgoCD](https://argoproj.github.io/cd/) instance running in the cluster eventually. You can then
install your applications using the GitOps approach. Have a look at `install_argocd_app_of_apps` and the related
configuration variables for further options.

The main idea is to provision the Kubernetes cluster and bootstrap [ArgoCD](https://argoproj.github.io/cd/) with infrastructure as code
using [OpenTofu](https://opentofu.org/). So it can be rolled out very quickly and consistently. All other Kubernetes resources are then
installed with [ArgoCD](https://argoproj.github.io/cd/) using a git repository.

Usually you want to keep your Kubernetes cluster infrastructure and the Kubernetes resources in a separate repositories.
That way you have everything decoupled, and you can migrate your applications to a new cluster infrastructure more easily.
I added the Kubernetes resources in the `argocd` directory mainly for demonstration purposes.

### Proxmox VE
First step is to provision the Proxmox part: create a `configuration.auto.tfvars` file based on the example and
edit it so it suits your needs. For each control plane and worker node in `node_data`, the `hostname`, CPU cores,
memory and disk size are optional and fall back to sensible defaults. When you omit the `hostname`, Talos Linux
generates one itself:
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
$ tofu output -raw kubeconfig > ~/.kube/config
$ chmod 600 ~/.kube/config
```
Test if your cluster access works by listing the nodes:
```shell
$ kubectl get nodes
NAME                          STATUS   ROLES           AGE   VERSION
your-cluster-name-cp-0        Ready    control-plane   5d    v1.36.3
your-cluster-name-worker-0    Ready    <none>          5d    v1.36.3
```
You might need to wait a bit until the nodes come up. Proceed with the next step when all nodes are in the `Ready`
state.

### Kubernetes
Secondly, you can provision the resources inside the Kubernetes cluster. You have a couple of options to choose 
from. All options can be configured using variables in `configuration.auto.tfvars`:
1. **Quick start**: installs Cilium LB config, ArgoCD, Ingress without TLS (default settings) with OpenTofu. [ArgoCD](https://argoproj.github.io/cd/) is
   available on http://argocd.local.
   * install_cilium_lb_config = true
   * argocd_helm_values: [see defaults in variables.tf](kubernetes/variables.tf)
   * install_argocd_app_of_apps = false
   * install_argocd_app_of_apps_git_repo_secret = false
2. **GitOps using your own repository**: installs ArgoCD, no Cilium LB config, no Ingress and the Kubernetes resources in
   the repository you specify in `argocd_app_of_apps_source`. Credentials for a private repository can be configured
   and installed with OpenTofu using `install_argocd_app_of_apps_git_repo_secret` and the related variables:
   * install_cilium_lb_config = false
   * argocd_helm_values/argocd_helm_yaml_values: add your Helm values and override defaults, for instance keep server insecure and switch off ingress
   * install_argocd_app_of_apps = true
   * argocd_app_of_apps_source = YOUR SOURCE SETTINGS
   * install_argocd_app_of_apps_git_repo_secret = true
   * argocd_app_of_apps_git_repo_secret_url = "https://github.com/you/yourrepo.git"
   * argocd_app_of_apps_git_repo_secret_password_or_token = "github_pat_OLImf09435459hfjoi9m435298524jtfjn45i8tmnmds329023jdhn"

These are two use cases I envision here. Please regard them as examples. Of course, you can combine the variables to
any other setup which suits your needs.

#### Quick start
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
ArgoCD web user interface should be up and running by now. You can access it in your web browser on
http://argocd.local if you didn't change the defaults or under the domain you configured with `argocd_domain`.

Or log in using ArgoCD CLI (if [installed](https://argo-cd.readthedocs.io/en/stable/cli_installation/))
and check on sync status of your apps:
```shell
$ argocd login --port-forward --port-forward-namespace argocd --plaintext
$ argocd app list --port-forward --port-forward-namespace argocd --plaintext
```

#### GitOps Quick Start
For doing a **GitOps quick start** you can fork this repository and point the `argocd_app_of_apps_source` to the 
`argocd` directory of your newly forked repository. This way you can make use of the example Kubernetes resources in
`argocd` directory and edit them to match your infrastructure.

## Upgrading
Talos OS and Kubernetes versions are managed declaratively through the `talos_machine` resource
(`proxmox/talos_linux.tf`), part of the [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
v0.12 alpha line. On every `tofu plan`/`apply` the provider reads the running Talos version and the
active machine configuration hash from each node; changing `talos_version`/`install_image` or
`kubernetes_version` in `configuration.auto.tfvars` and re-applying reconciles the drift.

Gracefully orchestrating in-place upgrades through Terraform/OpenTofu is a long-standing rough edge in
the Talos provider — see [siderolabs/terraform-provider-talos#140](https://github.com/siderolabs/terraform-provider-talos/issues/140)
for the multi-year discussion on graceful, node-by-node upgrades, and [#381](https://github.com/siderolabs/terraform-provider-talos/issues/381)
for clarification that changing `talos_version`, despite some contradictory wording across the
provider's docs, is in fact the supported way to trigger a Talos upgrade. The notes below reflect how
this repository actually wires up `talos_machine`/`talos_machine_bootstrap` today and what to watch
out for as a result.

### Upgrading Talos
1. Pick the new Talos version and update `talos_version`, `talos_linux_iso_image_url` and
   `talos_linux_iso_image_filename` in `configuration.auto.tfvars`.
2. For every node in `node_data`, update `install_image` to the matching version tag, e.g.
   `factory.talos.dev/nocloud-installer/<schematic-id>:v1.14.0`. The schematic ID stays the same
   across versions unless you change the extensions baked into the image on the
   [Talos Image Factory](https://factory.talos.dev/); only the version tag needs bumping.
3. Run `tofu plan` to confirm only the `image` field (and any machine config drift) is changing, not
   disk layout or network settings.
4. `node_data.controlplanes` and `node_data.workers` are each applied with `for_each` and have no
   `depends_on` chaining between individual nodes, so a plain `tofu apply` upgrades every node in
   parallel. For a multi-control-plane cluster this risks losing etcd quorum. Run
   `tofu apply -parallelism=1` instead to upgrade nodes one at a time — see the provider's
   [Upgrading multiple nodes safely](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine#upgrading-multiple-nodes-safely)
   guidance.
5. `drain_on_upgrade` is set to `false` for both control plane and worker `talos_machine` resources
   in `talos_linux.tf`, so nodes reboot without being cordoned/drained first — acceptable for a
   home-lab cluster that can tolerate brief pod disruption. If you want zero-disruption upgrades,
   wire `kubeconfig_wo = talos_cluster_kubeconfig.this.kubeconfig_raw` into both resources and set
   `drain_on_upgrade = true` (see the provider's
   [Draining nodes before upgrade](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine#draining-nodes-before-upgrade)).

### Upgrading Kubernetes
1. Update `kubernetes_version` in `configuration.auto.tfvars`.
2. This value feeds `data.talos_machine_configuration` for every node, changing the embedded
   `kubelet`, `kube-apiserver`, `kube-controller-manager`, `kube-scheduler` and `kube-proxy` image
   tags. Because this project doesn't use the newer `talos_cluster` resource or the
   `ignore_kubernetes_upgrade_drift` attribute on `talos_machine`, `tofu apply` re-applies those tags
   directly and in parallel across all nodes rather than following Talos's sequential, health-gated
   `upgrade-k8s` procedure.
3. For a small/home-lab cluster this is usually fine, but for a safer rollout run
   `tofu apply -parallelism=1` for this step too, or upgrade manually with `talosctl upgrade-k8s`
   first and only bump `kubernetes_version` afterwards, so `tofu plan` reports no drift on the next
   apply.

## Roadmap
Proxmox part:
* automate safe, node-by-node upgrade sequencing (draining, `-parallelism=1` equivalent via `depends_on`)
  for Talos/Kubernetes version bumps, see [Upgrading](#upgrading)

I am happy to receive pull requests for any improvements.

## Development
[Install uv](https://docs.astral.sh/uv/getting-started/installation/) and sync dependencies:
```shell
uv sync
```
Install git hooks:
```shell
pre-commit install --hook-type commit-msg --hook-type pre-commit --hook-type pre-push 
```

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* [Cilium documentation](https://docs.cilium.io/en/stable/)
* [Gateway API](https://gateway-api.sigs.k8s.io/)
* Terraform providers:
  * [terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox)
  * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
  * [terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes) 
  * [terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm)
* Helm charts:
  * [ArgoCD](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
  * [Cilium](https://artifacthub.io/packages/helm/cilium/cilium)