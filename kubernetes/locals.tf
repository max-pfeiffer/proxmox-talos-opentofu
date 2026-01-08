locals {
  argocd_values = concat(
    [
      {
        name  = "global.domain"
        value = var.argocd_domain
      },
    ],
    var.argocd_server_insecure ? [
      {
        name  = "configs.params.server\\.insecure"
        value = "true"
      },
      ] : [],
    var.argocd_ingress_enabled ? [
      {
        name  = "server.ingress.enabled"
        value = "true"
      },
      {
        name  = "server.ingress.ingressClassName"
        value = "cilium"
      },
    ] : []
  )
}
