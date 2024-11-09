resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
  }
}

resource "kubernetes_namespace" "persistence" {
  metadata {
    name = "persistence"
  }
}
