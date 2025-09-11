variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_target_node" {
  type = string
}

variable "proxmox_storage_device" {
  type = string
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk  = string
      install_image = string
      hostname      = optional(string)
    }))
    workers = map(object({
      install_disk  = string
      install_image = string
      hostname      = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "192.168.1.150" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.1"
      },
    }
    workers = {
      "192.168.1.151" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.1"
      },
      "192.168.1.152" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.11.1"
      }
    }
  }
}

variable "network" {
  description = "Network for all nodes"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway for all nodes"
  type        = string
}

variable "domain_name_server" {
  description = "DNS for all nodes"
  type        = string
}

variable "vip_shared_ip" {
  description = "Shared virtual IP address for control plane nodes"
  type        = string
  default     = "192.168.20.10"
}

variable "vlan_tag" {
  description = "Vlan tag for all nodes, default does not configure a Vlan"
  type        = number
  default     = 0
}

