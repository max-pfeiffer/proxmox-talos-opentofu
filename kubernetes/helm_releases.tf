resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace_v1.argocd]
  name       = "argo-cd"
  chart      = "argo-cd"
  version    = "9.2.4"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = kubernetes_namespace_v1.argocd.id
  timeout    = 120
  set        = var.argocd_helm_values
}

resource "helm_release" "cilium_lb_config" {
  count      = var.install_cilium_lb_config ? 1 : 0
  depends_on = [helm_release.argocd]
  name       = "cilium-lb-config"
  chart      = "${path.module}/helm_charts/cilium-lb-config"
  timeout    = 60
  set = [
    {
      name  = "ciliumLoadBalancerIpRange.start"
      value = var.cilium_load_balancer_ip_range_start
    },
    {
      name  = "ciliumLoadBalancerIpRange.stop"
      value = var.cilium_load_balancer_ip_range_stop
    },
  ]
}

resource "helm_release" "argocd_app_of_apps" {
  count      = var.install_argocd_app_of_apps ? 1 : 0
  depends_on = [helm_release.argocd]
  name       = "app-of-apps"
  chart      = "${path.module}/helm_charts/app-of-apps"
  namespace  = kubernetes_namespace_v1.argocd.id
  timeout    = 60
  set = [
    {
      name  = "source"
      value = var.argocd_app_of_apps_source
    },
    {
      name  = "syncPolicy"
      value = var.argocd_app_of_apps_sync_policy
    },
  ]
}