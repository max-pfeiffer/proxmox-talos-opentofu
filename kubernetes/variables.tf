variable "kubernetes_config_path" {
  type      = string
  sensitive = true
}

variable "Kubernetes_config_context" {
  type      = string
  sensitive = true
}

variable "cilium_load_balancer_ip_range_start" {
  type      = string
}

variable "cilium_load_balancer_ip_range_stop" {
  type      = string
}

variable "argocd_domain" {
  type      = string
}

