resource "proxmox_storage_iso" "talos_linux_iso_image" {
  url      = local.talos_linux_iso_image_url
  filename = local.talos_linux_iso_image_filename
  storage  = "local"
  pve_node = var.proxmox_target_node
}
