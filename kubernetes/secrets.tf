resource "kubernetes_secret_v1" "argocd_app_of_apps_git_repo" {
  count      = var.install_argocd_app_of_apps_git_repo_secret ? 1 : 0
  depends_on = [helm_release.argocd_app_of_apps]
  metadata {
    namespace = "argocd"
    name      = "argocd-app-of-apps-git-repo"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    type     = "git"
    url      = var.argocd_app_of_apps_git_repo_secret_url
    username = "git"
    password = var.argocd_app_of_apps_git_repo_secret_token
  }
}
