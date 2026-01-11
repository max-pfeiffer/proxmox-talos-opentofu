terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubernetes_config_path
  config_context = var.Kubernetes_config_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubernetes_config_path
    config_context = var.Kubernetes_config_context
  }
}
