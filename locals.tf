locals {
  repo_root = "${dirname(abspath(path.root))}"

  # Talos Linux
  talos_linux_iso_image_filename = "talos-linux-qemu-guest-agent-amd64.iso"

  # K8s control plane
  k8s_control_plane_ip_address = "192.168.1.150"

  # K8s worker 1
  k8s_worker_1_ip_address = "192.168.1.151"

  # K8s worker 2
  k8s_worker_2_ip_address = "192.168.1.152"
}
