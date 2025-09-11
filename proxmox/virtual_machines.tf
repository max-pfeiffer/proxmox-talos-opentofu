resource "proxmox_vm_qemu" "kubernetes_control_plane" {
  depends_on  = [proxmox_storage_iso.talos_linux_iso_image]
  for_each    = var.node_data.controlplanes
  name        = format("kubernetes-control-plane-%s", index(keys(var.node_data.controlplanes), each.key))
  description = "Kubernetes Control Plane"
  target_node = var.proxmox_target_node
  agent       = 1
  vm_state    = "running"
  memory      = 8192
  boot        = "order=virtio0;ide2"

  cpu {
    cores = 2
  }

  vga {
    type = "std"
  }

  disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = var.proxmox_storage_device
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = "local:iso/${local.talos_linux_iso_image_filename}"
  }

  disk {
    slot    = "virtio0"
    type    = "disk"
    storage = var.proxmox_storage_device
    size    = "10240M"
    discard = true
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = var.vlan_tag
  }

  # Cloud init setup
  os_type   = "cloud-init"
  ipconfig0 = "ip=${each.key}/24,gw=${var.network_gateway}"
}


resource "proxmox_vm_qemu" "kubernetes_worker" {
  depends_on  = [proxmox_storage_iso.talos_linux_iso_image]
  for_each    = var.node_data.workers
  name        = format("kubernetes-worker-%s", index(keys(var.node_data.workers), each.key))
  description = "Kubernetes Worker Node"
  target_node = var.proxmox_target_node
  agent       = 1
  vm_state    = "running"
  memory      = 16384
  boot        = "order=virtio0;ide2"

  cpu {
    cores = 2
  }

  vga {
    type = "std"
  }

  disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = var.proxmox_storage_device
  }

  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = "local:iso/${local.talos_linux_iso_image_filename}"
  }

  disk {
    slot    = "virtio0"
    type    = "disk"
    storage = var.proxmox_storage_device
    size    = "10240M"
    discard = true
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = var.vlan_tag
  }

  # Cloud init setup
  os_type   = "cloud-init"
  ipconfig0 = "ip=${each.key}/24,gw=${var.network_gateway}"
}
