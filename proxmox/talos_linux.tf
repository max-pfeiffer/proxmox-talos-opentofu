resource "talos_machine_secrets" "this" {}

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
        hostname             = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.controlplanes), each.key)) : each.value.hostname
        install_disk         = each.value.install_disk
        install_image        = each.value.install_image
        dns                  = var.domain_name_server
        ip_address           = "${each.key}/24"
        network              = var.network
        network_gateway      = var.network_gateway
        vip_shared_ip        = var.cluster_vip_shared_ip
        gateway_api_manifest = file("${path.module}/gateway-api/gateway-api-crds-v1.3.yaml")
        cilium_manifest      = data.helm_template.cilium.manifest
      }),
    ],
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
        hostname        = each.value.hostname == null ? format("%s-worker-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
        install_disk    = each.value.install_disk
        install_image   = each.value.install_image
        dns             = var.domain_name_server
        ip_address      = "${each.key}/24"
        network         = var.network
        network_gateway = var.network_gateway
      }),
    ],
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
}

resource "talos_machine" "worker" {
  depends_on = [proxmox_virtual_environment_vm.kubernetes_worker]
  for_each   = var.node_data.workers

  node                  = each.key
  client_configuration  = talos_machine_secrets.this.client_configuration
  machine_configuration = data.talos_machine_configuration.worker[each.key].machine_configuration
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
  endpoint             = var.cluster_vip_shared_ip
}
