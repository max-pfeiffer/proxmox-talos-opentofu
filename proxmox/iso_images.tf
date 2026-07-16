resource "proxmox_download_file" "talos_linux_iso_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_target_node
  url          = var.talos_linux_iso_image_url
  file_name    = var.talos_linux_iso_image_filename
}
