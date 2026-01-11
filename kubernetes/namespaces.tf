resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}