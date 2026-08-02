resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.12.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "45s"
}

resource "helm_release" "rancher" {
  depends_on = [time_sleep.wait_for_cert_manager]

  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
#   version          = "2.8.2"

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set_sensitive {
    name  = "bootstrapPassword"
    value = var.rancher_admin_password
  }
  set {
    name  = "replicas"
    value = "1" # Save resources for local testing
  }
}


provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://localhost:8443"
  bootstrap = true
  insecure  = true
}

resource "rancher2_bootstrap" "admin" {
  depends_on = [helm_release.rancher]
  provider       = rancher2.bootstrap
  password       = var.rancher_admin_password
  initial_password = var.rancher_admin_password
}