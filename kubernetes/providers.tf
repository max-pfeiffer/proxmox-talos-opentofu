terraform {
        required_providers {
            kubernetes = {
                  source = "opentofu/kubernetes"
                  version = "2.32.0"
            }
            helm = {
                  source = "opentofu/helm"
                  version = "2.15.0"
                }
        }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}