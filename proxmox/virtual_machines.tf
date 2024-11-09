resource "proxmox_vm_qemu" "k8s_control_plane" {
        depends_on = [proxmox_storage_iso.talos_linux_iso_image]
        name = "k8s-control-plane"
        desc = "Control Node"
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
        ipconfig0 = "ip=${local.k8s_control_plane_ip_address}/24,gw=192.168.1.1"
}


resource "proxmox_vm_qemu" "k8s_worker_1" {
        depends_on = [proxmox_storage_iso.talos_linux_iso_image]
        name = "k8s-worker-1"
        desc = "Worker Node 1"
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
        ipconfig0 = "ip=${local.k8s_worker_1_ip_address}/24,gw=192.168.1.1"
}


resource "proxmox_vm_qemu" "k8s_worker_2" {
        depends_on = [proxmox_storage_iso.talos_linux_iso_image]
        name = "k8s-worker-2"
        desc = "Worker Node 2"
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
        ipconfig0 = "ip=${local.k8s_worker_2_ip_address}/24,gw=192.168.1.1"
}
