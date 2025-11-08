data "helm_template" "cilium" {
  name         = "cilium"
  namespace    = "kube-system"
  repository   = "https://helm.cilium.io"
  chart        = "cilium"
  version      = "1.18.3"
  kube_version = var.kubernetes_version
  set = [
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
    {
      name  = "kubeProxyReplacement"
      value = "true"
    },
    {
      name  = "securityContext.capabilities.ciliumAgent"
      value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
    },
    {
      name  = "securityContext.capabilities.cleanCiliumState"
      value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
    },
    {
      name  = "cgroup.autoMount.enabled"
      value = "false"
    },
    {
      name  = "cgroup.hostRoot"
      value = "/sys/fs/cgroup"
    },
    {
      name  = "k8sServiceHost"
      value = "localhost"
    },
    {
      name  = "k8sServicePort"
      value = "7445"
    },
    # L2 Loadbalancer
    # See: https://docs.cilium.io/en/stable/network/l2-announcements/
    {
      name  = "l2announcements.enabled"
      value = "true"
    },
    {
      name  = "k8sClientRateLimit.qps"
      value = "50"
    },
    {
      name  = "k8sClientRateLimit.burst"
      value = "100"
    },
    # Ingress Controller
    # See: https://docs.cilium.io/en/stable/network/servicemesh/ingress/
    {
      name  = "ingressController.enabled"
      value = "true"
    },
    {
      name  = "ingressController.loadbalancerMode"
      value = "dedicated"
    },
    # Gateway API
    # See: https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAlpn"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAppProtocol"
      value = "true"
    },
    {
      name  = "gatewayAPI.gatewayClass.create"
      value = "true"
      type = "string"
    },
    # Egress Gateway
    # See: https://docs.cilium.io/en/stable/network/egress-gateway/egress-gateway/
    {
      name  = "egressGateway.enabled"
      value = "true"
    },
    {
      name  = "bpf.masquerade"
      value = "true"
    },
  ]
}