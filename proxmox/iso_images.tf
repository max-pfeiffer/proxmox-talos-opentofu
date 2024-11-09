resource "proxmox_storage_iso" "talos_linux_iso_image" {
        url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.2/nocloud-amd64.iso"
        filename = local.talos_linux_iso_image_filename
        storage = "local"
        pve_node = var.proxmox_target_node
}
