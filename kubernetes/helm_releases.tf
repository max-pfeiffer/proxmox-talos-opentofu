resource "helm_release" "argocd" {
  name             = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  chart            = "argo-cd"
  version          = "9.2.4"
  repository       = "https://argoproj.github.io/argo-helm"
  timeout          = 120
  set              = local.argocd_values
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
  name       = "cilium-lb-config"
  chart      = "${path.module}/helm_charts/cilium-lb-config"
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