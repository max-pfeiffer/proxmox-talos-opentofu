resource "helm_release" "argocd" {
  name             = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  chart            = "argo-cd"
  version          = "9.1.0"
  repository       = "https://argoproj.github.io/argo-helm"
  timeout          = 120
  set = [
    {
      name  = "global.domain"
      value = var.argocd_domain
    },
    {
      name  = "configs.params.server\\.insecure"
      value = "true"
    },
    {
      name  = "server.ingress.enabled"
      value = "true"
    },
    {
      name  = "server.ingress.ingressClassName"
      value = "cilium"
    },
    {
      name  = "server.ingress.annotations.ingress\\.cilium\\.io/force-https"
      value = "disabled"
    },
  ]
}

resource "helm_release" "cilium_lb_config" {
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
