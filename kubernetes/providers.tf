terraform {
        required_providers {
            kubernetes = {
                  source = "opentofu/kubernetes"
                  version = "2.32.0"
            }
        }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
