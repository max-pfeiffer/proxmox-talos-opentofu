variable "kubernetes_config_path" {
  type      = string
  sensitive = true
}

variable "Kubernetes_config_context" {
  type      = string
  sensitive = true
}

variable "install_cilium_lb_config" {
  type    = bool
  default = true
}

variable "cilium_load_balancer_ip_range_start" {
  type = string
}

variable "cilium_load_balancer_ip_range_stop" {
  type = string
}

variable "argocd_domain" {
  type = string
}

variable "argocd_server_insecure" {
  type    = bool
  default = true
}

variable "argocd_ingress_enabled" {
  type    = bool
  default = true
}

variable "install_argocd_app_of_apps" {
  type    = bool
  default = false
}

variable "argocd_app_of_apps_source" {
  type    = string
  default = <<-EOT
repoURL: https://github.com/max-pfeiffer/proxmox-talos-opentofu
targetRevision: feature/make-gitops-part-configurable
path: argocd
directory:
  recurse: true
EOT
}

variable "argocd_app_of_apps_sync_policy" {
  type    = string
  default = <<-EOT
automated:
  prune: true
  selfHeal: true
syncOptions:
- SkipDryRunOnMissingResource=true
EOT
}

variable "install_argocd_app_of_apps_git_repo_secret" {
  type    = bool
  default = false
}

variable "argocd_app_of_apps_git_repo_secret_url" {
  type    = string
  default = ""
}

variable "argocd_app_of_apps_git_repo_secret_token" {
  type    = string
  default = ""
}
