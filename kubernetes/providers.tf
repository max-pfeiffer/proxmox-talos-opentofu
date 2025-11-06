terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubernetes_config_path
    config_context = var.Kubernetes_config_context
  }
}
