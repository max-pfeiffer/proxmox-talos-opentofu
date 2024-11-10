resource "proxmox_vm_qemu" "kubernetes_control_plane" {
        depends_on = [proxmox_storage_iso.talos_linux_iso_image]
        for_each = var.node_data.controlplanes
        name = format("kubernetes-control-plane-%s", index(keys(var.node_data.controlplanes), each.key))
        desc = "Kubernetes Control Plane"
        target_node = var.proxmox_target_node
        agent = 1
        vm_state = "running"
        cores = 2
        memory = 4096
        boot = "order=virtio0;ide2"

        vga {
                type = "std"
        }

        disk {
                slot = "ide0"
                type = "cloudinit"
                storage = "local-lvm"
        }

        disk {
                slot = "ide2"
                type = "cdrom"
                iso = "local:iso/${local.talos_linux_iso_image_filename}"
        }

        disk {
                slot = "virtio0"
                type = "disk"
                storage = "local-lvm"
                size = "10240M"
                discard = true
        }

        network {
                model = "virtio"
                bridge = "vmbr0"
        }

        # Cloud init setup
        os_type = "cloud-init"
        ipconfig0 = "ip=${each.key}/24,gw=192.168.1.1"
}


resource "proxmox_vm_qemu" "kubernetes_worker" {
        depends_on = [proxmox_storage_iso.talos_linux_iso_image]
        for_each = var.node_data.workers
        name = format("kubernetes-worker-%s", index(keys(var.node_data.workers), each.key))
        desc = "Kubernetes Worker Node"
        target_node = var.proxmox_target_node
        agent = 1
        vm_state = "running"
        cores = 2
        memory = 8192
        boot = "order=virtio0;ide2"

        vga {
                type = "std"
        }

        disk {
                slot = "ide0"
                type = "cloudinit"
                storage = "local-lvm"
        }

        disk {
                slot = "ide2"
                type = "cdrom"
                iso = "local:iso/${local.talos_linux_iso_image_filename}"
        }

        disk {
                slot = "virtio0"
                type = "disk"
                storage = "local-lvm"
                size = "10240M"
                discard = true
        }

        network {
                model = "virtio"
                bridge = "vmbr0"
        }

        # Cloud init setup
        os_type = "cloud-init"
        ipconfig0 = "ip=${each.key}/24,gw=192.168.1.1"
}
