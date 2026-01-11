variable "kubernetes_config_path" {
  description = "Path to kubeconfig for this cluster"
  type        = string
  sensitive   = true
}

variable "Kubernetes_config_context" {
  description = "Name of the Kubernetes context in kubeconfig"
  type        = string
  sensitive   = true
}

variable "install_cilium_lb_config" {
  description = "Flag for installing CiliumL2AnnouncementPolicy and CiliumLoadBalancerIPPool via the Helm chart with OpenTofu"
  type        = bool
  default     = true
}

variable "cilium_load_balancer_ip_range_start" {
  description = "IP range start for CiliumLoadBalancerIPPool in Helm chart"
  type        = string
}

variable "cilium_load_balancer_ip_range_stop" {
  description = "IP range stop for CiliumLoadBalancerIPPool in Helm chart"
  type        = string
}

variable "argocd_domain" {
  description = "The FQDN for ArgoCD application"
  type        = string
}

# See: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#configuring-tls-for-argocd-server
variable "argocd_server_insecure" {
  description = "Flag for disabling internal TLS with --insecure in ArgoCD Helm chart"
  type        = bool
  default     = true
}

variable "argocd_ingress_enabled" {
  description = "Flag for enabling/disabling creating an Ingress in ArgoCD Helm chart"
  type        = bool
  default     = true
}

# See: https://argo-cd.readthedocs.io/en/latest/operator-manual/cluster-bootstrapping/#app-of-apps-pattern
variable "install_argocd_app_of_apps" {
  description = "Flag for bootstrapping ArgoCD with an App of Apps"
  type        = bool
  default     = false
}

# See: https://argo-cd.readthedocs.io/en/latest/user-guide/application-specification/
variable "argocd_app_of_apps_source" {
  description = "Source section of ArgoCD Application CRD, use it to configure a git repository of your choice"
  type        = string
  default     = <<-EOT
repoURL: https://github.com/max-pfeiffer/proxmox-talos-opentofu.git
targetRevision: feature/make-gitops-part-configurable
path: argocd
directory:
  recurse: true
EOT
}

# See: https://argo-cd.readthedocs.io/en/latest/user-guide/application-specification/
variable "argocd_app_of_apps_sync_policy" {
  description = "syncPolicy section of ArgoCD Application CRD, use it to configure syncPolicy settings of your choice"
  type        = string
  default     = <<-EOT
automated:
  prune: true
  selfHeal: true
syncOptions:
- SkipDryRunOnMissingResource=true
EOT
}

# See: https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/
variable "install_argocd_app_of_apps_git_repo_secret" {
  description = "Flag for provisioning the credentials for a private App of Apps repo in ArgoCD namespace with OpenTofu"
  type        = bool
  default     = false
}

variable "argocd_app_of_apps_git_repo_secret_url" {
  description = "Repository URL for your private App of Apps repository"
  type        = string
  default     = "https://github.com/max-pfeiffer/proxmox-talos-opentofu.git"
}

variable "argocd_app_of_apps_git_repo_secret_username" {
  description = "Username for your private App of Apps repository"
  type        = string
  default     = "git"
}

variable "argocd_app_of_apps_git_repo_secret_password_or_token" {
  description = "Password or token for your private App of Apps repository"
  type        = string
  default     = "yourtoken"
}
