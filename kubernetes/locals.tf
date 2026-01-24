locals {
  argocd_values = concat(
    [
      {
        name  = "global.domain"
        value = var.argocd_domain
      },

      # repo-server
      { name = "repoServer.livenessProbe.initialDelaySeconds", value = "60" },
      { name = "repoServer.livenessProbe.timeoutSeconds",      value = "5"  },
      { name = "repoServer.livenessProbe.periodSeconds",       value = "20" },
      { name = "repoServer.livenessProbe.failureThreshold",    value = "6"  },

      { name = "repoServer.readinessProbe.initialDelaySeconds", value = "30" },
      { name = "repoServer.readinessProbe.timeoutSeconds",      value = "5"  },
      { name = "repoServer.readinessProbe.periodSeconds",       value = "10" },
      { name = "repoServer.readinessProbe.failureThreshold",    value = "6"  },

      { name = "repoServer.resources.requests.cpu",    value = "100m" },
      { name = "repoServer.resources.requests.memory", value = "256Mi" },
      { name = "repoServer.resources.limits.memory",   value = "512Mi" },
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

