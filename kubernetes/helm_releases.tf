resource "helm_release" "argocd" {
  name       = "argo-cd"
  namespace = "argocd"
  create_namespace = true
  chart      = "argo-cd"
  version    = "8.3.1"
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 120
}
