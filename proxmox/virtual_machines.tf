resource "proxmox_virtual_environment_vm" "kubernetes_control_plane" {
  depends_on      = [proxmox_download_file.talos_linux_iso_image]
  for_each        = var.node_data.controlplanes
  name            = format("%s-kubernetes-control-plane-%s", var.cluster_name, index(keys(var.node_data.controlplanes), each.key))
  description     = "Kubernetes Control Plane"
  node_name       = var.proxmox_target_node
  started         = true
  stop_on_destroy = true
  boot_order      = ["virtio0", "ide2"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  vga {
    type = "std"
  }

  cdrom {
    interface = "ide2"
    file_id   = proxmox_download_file.talos_linux_iso_image.id
  }

  disk {
    interface    = "virtio0"
    datastore_id = var.proxmox_storage_device
    size         = each.value.disk_size
    discard      = "on"
  }

  network_device {
    model   = "virtio"
    bridge  = "vmbr0"
    vlan_id = var.vlan_tag
  }

  # Cloud init setup
  initialization {
    interface    = "ide0"
    datastore_id = var.proxmox_storage_device

    ip_config {
      ipv4 {
        address = "${each.key}/24"
        gateway = var.network_gateway
      }
    }

    dns {
      servers = [var.domain_name_server]
    }
  }
}


resource "proxmox_virtual_environment_vm" "kubernetes_worker" {
  depends_on      = [proxmox_download_file.talos_linux_iso_image]
  for_each        = var.node_data.workers
  name            = format("%s-kubernetes-worker-%s", var.cluster_name, index(keys(var.node_data.workers), each.key))
  description     = "Kubernetes Worker Node"
  node_name       = var.proxmox_target_node
  started         = true
  stop_on_destroy = true
  boot_order      = ["virtio0", "ide2"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  vga {
    type = "std"
  }

  cdrom {
    interface = "ide2"
    file_id   = proxmox_download_file.talos_linux_iso_image.id
  }

  disk {
    interface    = "virtio0"
    datastore_id = var.proxmox_storage_device
    size         = each.value.disk_size
    discard      = "on"
  }

  network_device {
    model   = "virtio"
    bridge  = "vmbr0"
    vlan_id = var.vlan_tag
  }

  # Cloud init setup
  initialization {
    interface    = "ide0"
    datastore_id = var.proxmox_storage_device

    ip_config {
      ipv4 {
        address = "${each.key}/24"
        gateway = var.network_gateway
      }
    }

    dns {
      servers = [var.domain_name_server]
    }
  }
}
