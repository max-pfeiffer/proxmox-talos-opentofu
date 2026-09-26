[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json)](https://github.com/astral-sh/uv)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-FFDA18?logo=opentofu&logoColor=black)](https://opentofu.org/)
[![Code quality](https://github.com/max-pfeiffer/proxmox-talos-opentofu/actions/workflows/code-quality.yaml/badge.svg)](https://github.com/max-pfeiffer/proxmox-talos-opentofu/actions/workflows/code-quality.yaml)
[![Release](https://github.com/max-pfeiffer/proxmox-talos-opentofu/actions/workflows/release.yaml/badge.svg)](https://github.com/max-pfeiffer/proxmox-talos-opentofu/actions/workflows/release.yaml)

# Proxmox Talos OpenTofu - Turnkey Kubernetes Cluster
A turnkey Kubernetes cluster built with [Talos Linux](https://www.talos.dev/) running on a
[Proxmox VE hypervisor](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).
Provisioning is done with [OpenTofu](https://opentofu.org/).

Kubernetes cluster features:
* [Talos Linux v1.13.8](https://www.talos.dev/) 
* Kubernetes v1.36.3
* no kube-proxy
* [Cilium v1.20.0](https://cilium.io/) as Container Network Interface (CNI) 
  * without kube-proxy
  * with [L2 loadbalancer support](https://docs.cilium.io/en/stable/network/l2-announcements/)
  * with [Ingress controller support](https://docs.cilium.io/en/stable/network/servicemesh/ingress/)
  * with [Gateway API support](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
  * with [Egress gateway support](https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway/)
* [Gateway API v1.6.1](https://gateway-api.sigs.k8s.io/) CRDs (standard channel) are installed 
* [ArgoCD v3.5.1](https://argoproj.github.io/cd/)

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
Talos OS and Kubernetes versions are managed declaratively in `proxmox/talos_linux.tf` through the
[terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos) v0.12.0 resources:

* `talos_machine` owns each node's machine configuration and its Talos OS version. On every
  `tofu plan`/`apply` the provider reads the running Talos version, the active Image Factory
  schematic and the applied machine configuration hash from the node and reconciles any drift.
* `talos_cluster` bootstraps etcd and owns the Kubernetes version. Changing its `kubernetes_version`
  runs Talos' `upgrade-k8s` procedure, which pre-pulls images and upgrades kube-apiserver,
  kube-controller-manager, kube-scheduler, kube-proxy and the kubelets sequentially with health
  gating.

Gracefully orchestrating in-place upgrades through Terraform/OpenTofu has long been a rough edge in
the Talos provider — see [siderolabs/terraform-provider-talos#140](https://github.com/siderolabs/terraform-provider-talos/issues/140)
for the multi-year discussion on graceful, node-by-node upgrades. The notes below reflect how this
repository wires up `talos_machine`/`talos_cluster` today and what to watch out for as a result.

### Upgrading Talos
1. Pick the new Talos version and update `talos_linux_iso_image_url` and
   `talos_linux_iso_image_filename` in `configuration.auto.tfvars`.
2. For every node in `node_data`, update `install_image` to the matching version tag, e.g.
   `factory.talos.dev/nocloud-installer/<schematic-id>:v1.14.0`. The schematic ID stays the same
   across versions unless you change the extensions baked into the image on the
   [Talos Image Factory](https://factory.talos.dev/); only the version tag needs bumping.
   `install_image` alone drives the OS upgrade.
3. Leave `talos_version` alone. It is the *machine configuration contract*, pinned to the version the
   cluster was created with, and is independent of the installed Talos version — the provider's docs
   make this [explicit](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration)
   as of v0.12.0. Bumping it regenerates every node's machine configuration with the new contract's
   schema and defaults, which is a separate, deliberate action, not part of a routine OS upgrade.
   (Earlier revisions of this README advised bumping it alongside `install_image`, following
   [#381](https://github.com/siderolabs/terraform-provider-talos/issues/381); v0.12.0 supersedes
   that.)
4. Run `tofu plan` to confirm only the `image` field (and any machine config drift) is changing, not
   disk layout or network settings.
5. `node_data.controlplanes` and `node_data.workers` are each applied with `for_each` and have no
   `depends_on` chaining between individual nodes, so a plain `tofu apply` upgrades every node in
   parallel. For a multi-control-plane cluster this risks losing etcd quorum. Run
   `tofu apply -parallelism=1` instead to upgrade nodes one at a time — see the provider's
   [Upgrading multiple nodes safely](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine#upgrading-multiple-nodes-safely)
   guidance.
6. `drain_on_upgrade` is `true` for both control plane and worker `talos_machine` resources, so each
   node is cordoned and drained before it reboots and uncordoned afterwards. The kubeconfig needed
   for that comes from the `ephemeral "talos_cluster_kubeconfig" "drain"` block, which derives it
   offline from the machine secrets rather than reading it back from the Talos API — that is what
   keeps it free of a dependency cycle with `talos_machine`, and being ephemeral it never lands in
   state. Draining requires a healthy Kubernetes cluster, so keep the ISO version and `install_image`
   in step (1)/(2) in sync: an upgrade that fires during the *initial* bring-up, before Kubernetes
   exists, would fail on the drain.

### Upgrading Kubernetes
1. Update `kubernetes_version` in `configuration.auto.tfvars`.
2. The value feeds both `talos_cluster` and `data.talos_machine_configuration`. `talos_cluster`
   performs the actual rolling upgrade via `upgrade-k8s`; the data source only controls the image
   tags baked into the generated configuration, which matter at bootstrap when a node is added
   later, so the two must stay in sync — a single variable feeds both.
3. Both `talos_machine` resources set `ignore_kubernetes_upgrade_drift = true`, so the five
   Kubernetes component image fields owned by `upgrade-k8s` (`machine.kubelet.image`,
   `cluster.apiServer.image`, `cluster.controllerManager.image`, `cluster.scheduler.image`,
   `cluster.proxy.image`) are excluded from `talos_machine`'s drift detection. Without it,
   `tofu apply` would re-apply those tags directly and in parallel across all nodes, bypassing
   `upgrade-k8s`'s sequencing. Note that the attribute is flagged experimental by the provider: only
   the version tag is stripped from the hash, so a registry change is still detected as drift.
4. A plain `tofu apply` is safe here — `talos_cluster` does the sequencing and health gating itself,
   so `-parallelism=1` is not needed for this step.

### Migrating an existing cluster to the v0.12.0 resources
If you are running an already bootstrapped cluster from an earlier revision of this repository, the
switch from `talos_machine_bootstrap` to `talos_cluster` shows up in the plan as one destroy and one
create. Both are safe against a live cluster: `talos_machine_bootstrap`'s destroy is a no-op that only
drops the resource from state, and `talos_cluster`'s create treats an already bootstrapped etcd as
success before running the Talos-layer health checks. Enabling `ignore_kubernetes_upgrade_drift` also
changes how the machine configuration hash is computed, so expect a one-time in-place update of each
`talos_machine` to refresh that hash. Run `tofu plan` first and confirm you see no `image` change and
no resource *replacement* — a replacement of `talos_machine` would reset the node.

## Roadmap
Proxmox part:
* automate safe, node-by-node Talos OS upgrade sequencing (a `-parallelism=1` equivalent via
  `depends_on` chaining between nodes) for `install_image` bumps, see [Upgrading](#upgrading).
  Draining and Kubernetes upgrade sequencing are already handled by `drain_on_upgrade` and
  `talos_cluster` respectively.

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