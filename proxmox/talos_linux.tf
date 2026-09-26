resource "talos_machine_secrets" "this" {}

# Kubeconfig used solely to cordon/drain nodes during Talos OS upgrades. It is derived
# offline from the machine secrets instead of being read back from the Talos API, so —
# unlike talos_cluster_kubeconfig.this — it does not depend on the cluster being
# bootstrapped and introduces no dependency cycle with talos_machine. Being an ephemeral
# resource, the kubeconfig never lands in state.
ephemeral "talos_cluster_kubeconfig" "drain" {
  cluster_name    = var.cluster_name
  machine_secrets = talos_machine_secrets.this.machine_secrets
  endpoint        = "https://${var.cluster_vip_shared_ip}:6443"
}

data "talos_machine_configuration" "controlplane" {
  for_each           = var.node_data.controlplanes
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_vip_shared_ip}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = concat(
    [
      templatefile("${path.module}/templates/machine_config_patches_controlplane.tftpl", {
        install_disk         = each.value.install_disk
        install_image        = each.value.install_image
        dns                  = var.domain_name_server
        ip_address           = "${each.key}/24"
        network              = var.network
        network_gateway      = var.network_gateway
        vip_shared_ip        = var.cluster_vip_shared_ip
        gateway_api_manifest = file("${path.module}/gateway-api/gateway-api-crds-v1.6.1.yaml")
        cilium_manifest      = data.helm_template.cilium.manifest
      }),
    ],
    # Without a hostname Talos Linux generates one itself
    each.value.hostname != null ? [
      templatefile("${path.module}/templates/machine_config_patch_hostname.tftpl", {
        hostname = each.value.hostname
      })
    ] : [],
    var.talos_machine_config_patch_controlplane != "" ? [var.talos_machine_config_patch_controlplane] : []
  )
}

data "talos_machine_configuration" "worker" {
  for_each           = var.node_data.workers
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_vip_shared_ip}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = concat(
    [
      templatefile("${path.module}/templates/machine_config_patches_worker.tftpl", {
        install_disk    = each.value.install_disk
        install_image   = each.value.install_image
        dns             = var.domain_name_server
        ip_address      = "${each.key}/24"
        network         = var.network
        network_gateway = var.network_gateway
      }),
    ],
    # Without a hostname Talos Linux generates one itself
    each.value.hostname != null ? [
      templatefile("${path.module}/templates/machine_config_patch_hostname.tftpl", {
        hostname = each.value.hostname
      })
    ] : [],
    var.talos_machine_config_patch_worker != "" ? [var.talos_machine_config_patch_worker] : []
  )
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = concat([var.cluster_vip_shared_ip], [for k, v in var.node_data.controlplanes : k])
}

resource "talos_machine" "controlplane" {
  depends_on = [proxmox_virtual_environment_vm.kubernetes_control_plane]
  for_each   = var.node_data.controlplanes

  node                  = each.key
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  image                 = each.value.install_image
  drain_on_upgrade      = true
  kubeconfig_wo         = ephemeral.talos_cluster_kubeconfig.drain.kubeconfig_raw

  # Kubernetes component image tags are owned by talos_cluster, which upgrades them
  # through Talos' sequential, health-gated upgrade-k8s procedure. Excluding them from
  # drift detection keeps this resource from re-applying them in parallel and bypassing it.
  ignore_kubernetes_upgrade_drift = true
}

resource "talos_machine" "worker" {
  depends_on = [proxmox_virtual_environment_vm.kubernetes_worker]
  for_each   = var.node_data.workers

  node                  = each.key
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.worker[each.key].machine_configuration
  image                 = each.value.install_image
  drain_on_upgrade      = true
  kubeconfig_wo         = ephemeral.talos_cluster_kubeconfig.drain.kubeconfig_raw

  ignore_kubernetes_upgrade_drift = true
}

# Bootstraps etcd and owns the Kubernetes version: changing kubernetes_version runs Talos'
# upgrade-k8s procedure, which upgrades the control plane components and kubelets
# sequentially with health gating. Bootstrapping is idempotent, so re-creating this
# resource against an already running cluster is a no-op followed by a health check.
resource "talos_cluster" "this" {
  depends_on = [talos_machine.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(var.node_data.controlplanes)[0]
  control_plane_nodes  = keys(var.node_data.controlplanes)
  kubernetes_version   = var.kubernetes_version
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_cluster.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(var.node_data.controlplanes)[0]
  endpoint             = var.cluster_vip_shared_ip
}
